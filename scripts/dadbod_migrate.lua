-- One-time conversion of dadbod's connections.yaml from the old one-line format
--   name: url  # rw kube=<ns>/<type>/<name>[:<port>] ctx=<context>
-- to the YAML mappings read by dadbod_sync.lua (see its header). Unknown tags are kept as a
-- comment, comments are kept (except the old template header). The new file is checked with
-- yq before it replaces the old one, which stays next to it as connections.yaml.bak-<time>.
--
--   nvim -l dadbod_migrate.lua
--
-- Output never contains URLs or passwords: only connection names and short reasons.

local uv = vim.uv

local config_home = vim.env.XDG_CONFIG_HOME
if not config_home or config_home == '' then config_home = vim.env.HOME .. '/.config' end
local connections_path = config_home .. '/dadbod/connections.yaml'

local OLD_HEADER = {
  ['# One "name: url" per line, no quoting. {{dbname}} = pick the database when connecting.'] = true,
  ['# Saving syncs ~/.pg_service.conf (read-only for tools like pgro); end a line with "# rw" to allow writes.'] = true,
  ['# local: postgresql://user:pass@localhost:5432/{{dbname}}  # rw'] = true,
}
local NEW_HEADER = {
  '# dadbod connections by name. Saving syncs ~/.pg_service.conf for pgro (see scripts/dadbod_sync.lua).',
  '#   name: postgresql://user:pass@host:5432/{{dbname}}   # short form; {{dbname}} = pick the database',
  '#   name:',
  '#     url: postgresql://user:pass@localhost:15433/db',
  '#     rw: true                       # allow writes (default read-only)',
  '#     tunnel:                        # kubectl port-forward, started by pgro/dbtunnel',
  '#       kube: <ns>/<svc|pod|deploy|sts>/<name>[:<port>]',
  '#       context: <kube context>',
  '',
}

-- JSON strings are valid YAML double-quoted scalars; plain style only when clearly safe
local function scalar(s)
  if s:match '^[%w_.:@/-]+$' and not s:match '^[%d.]' and not s:find ': ' then return s end
  return vim.json.encode(s)
end
local function key(s)
  local plain = s:match '^[%a_][%w_.-]*$' and not ({ ['true'] = 1, ['false'] = 1, ['null'] = 1 })[s:lower()]
  return plain and s or vim.json.encode(s)
end

local function main()
  local path = uv.fs_realpath(connections_path)
  local f = path and io.open(path, 'r')
  if not f then
    io.stderr:write('dadbod migrate: cannot read ' .. connections_path .. '\n')
    return 1
  end
  local lines = {}
  for line in f:lines() do lines[#lines + 1] = (line:gsub('\r$', '')) end
  f:close()

  local out, expected, warnings = vim.deepcopy(NEW_HEADER), {}, {}
  for i, line in ipairs(lines) do
    if line:match '^%s+$' then line = '' end
    if line:match '^%s' or line:match '^[^%s#][^%s:]*:%s*$' then
      io.stderr:write('dadbod migrate: line ' .. i .. ' is not in the old format (already migrated?), nothing changed\n')
      return 1
    end
    if line == '' then
      out[#out + 1] = ''
    elseif line:match '^#' then
      if not OLD_HEADER[line] then out[#out + 1] = line end
    else
      local name, url = line:match '^([^%s#:][^%s:]*):%s*(.+)$'
      if not name then
        io.stderr:write('dadbod migrate: line ' .. i .. ' is not "name: url", nothing changed\n')
        return 1
      end
      local tags = url:match '%s#(.*)$' or ''
      url = vim.trim((url:gsub('%s+#.*$', '')))
      local e, other = { name = name, url = url }, {}
      for word in tags:gmatch '%S+' do
        if word == 'rw' then
          e.rw = true
        elseif word:match '^kube=' then
          e.kube = word:sub(6)
        elseif word:match '^ctx=' then
          e.ctx = word:sub(5)
        else
          other[#other + 1] = word
        end
      end
      if #other > 0 then out[#out + 1] = '# old tags: ' .. table.concat(other, ' ') end
      out[#out + 1] = key(name) .. ':'
      out[#out + 1] = '  url: ' .. vim.json.encode(url)
      if e.rw then out[#out + 1] = '  rw: true' end
      if e.kube or e.ctx then
        out[#out + 1] = '  tunnel:'
        if e.kube then out[#out + 1] = '    kube: ' .. scalar(e.kube) end
        if e.ctx then out[#out + 1] = '    context: ' .. scalar(e.ctx) end
        if not (e.kube and e.ctx) then
          warnings[#warnings + 1] = name .. ': tunnel needs both kube: and context: (kube-db-pf used to ask'
            .. ' for the context); add the missing one or the sync skips this connection'
        end
      end
      expected[#expected + 1] = e
    end
  end
  local content = table.concat(out, '\n'):gsub('\n\n\n+', '\n\n') .. '\n'

  -- write next to the original (mode 600) and check it parses back to the same values
  local tmp = path .. '.tmp' .. uv.os_getpid()
  local fd = assert(uv.fs_open(tmp, 'wx', tonumber('600', 8)))
  local ok = uv.fs_write(fd, content) == #content
  uv.fs_close(fd)
  local res = ok and vim.system({ 'yq', '-o=json', 'to_entries', tmp }, { text = true }):wait()
  -- a decode error message could quote the content: never let it out
  local decoded = res and res.code == 0 and select(2, pcall(vim.json.decode, res.stdout))
  if type(decoded) ~= 'table' then decoded = {} end
  local bad = not ok or #decoded ~= #expected
  for i, e in ipairs(expected) do
    local d = decoded[i]
    local v, t = d and d.value or {}, d and d.value and d.value.tunnel or {}
    if bad or not d or d.key ~= e.name or v.url ~= e.url or (v.rw == true) ~= (e.rw == true)
      or t.kube ~= e.kube or t.context ~= e.ctx then
      bad = true
      io.stderr:write('dadbod migrate: check failed' .. (d and (' at ' .. e.name) or '') .. ', nothing changed\n')
      break
    end
  end
  if bad then
    if #expected == 0 then io.stderr:write('dadbod migrate: check failed, nothing changed\n') end
    uv.fs_unlink(tmp)
    return 1
  end

  local backup = path .. '.bak-' .. os.date '%Y%m%d%H%M%S'
  uv.fs_chmod(path, tonumber('600', 8))
  assert(uv.fs_rename(path, backup))
  assert(uv.fs_rename(tmp, path))
  io.stdout:write(('dadbod migrate: %d connection(s) converted, old file kept as %s\n'):format(#expected, backup))
  for _, w in ipairs(warnings) do io.stdout:write('  ' .. w .. '\n') end
  io.stdout:write('Now sync: save the file in nvim, or :DBSyncPgpass\n')
  return 0
end

local ok, res = pcall(main)
if not ok then
  io.stderr:write('dadbod migrate failed: ' .. tostring(res):gsub('^[^:]*:%d+: ', '') .. '\n')
  os.exit(1)
end
os.exit(res)
