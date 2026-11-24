-- Generate libpq config from dadbod's connections.yaml so tools (and Claude, via `pgro`)
-- can connect by connection name without ever seeing a password.
--
--   nvim -l dadbod_sync.lua
--
-- connections.yaml (parsed with yq), connection names as keys:
--   local: postgresql://user:pass@localhost:5432/{{dbname}}      # short form: just the URL
--   client_prod:
--     url: postgresql://user:pass@localhost:15433/{{dbname}}
--     rw: true                                 # optional, default false
--     tunnel:                                  # optional: kubectl port-forward (dbtunnel)
--       kube: <ns>/<svc|pod|deploy|sts>/<name>[:<remote port, default 5432>]
--       context: <kube context>
--
-- Writes:
--   ~/.pg_service.conf (or $PGSERVICEFILE): one [name] section per connection, inside a
--     "# BEGIN dadbod" / "# END dadbod" block; anything outside the block is kept.
--     Every service is read-only and has timeouts, except connections with `rw: true`:
--     those are marked "# dadbod: read-write" and get neither, and `pgro` lets anything
--     through on them. Connections with a tunnel get a "# dadbod: tunnel kube <context>
--     <ns> <type>/<name> <local port> <remote port>" marker, read by pgro and dbtunnel; the URL
--     must point at localhost (not port 5432, the local server), and tunnels sharing a local
--     port must have the same target.
--   $XDG_CONFIG_HOME/dadbod/pgpass.d/<name>: one pgpass line per connection (mode 600),
--     referenced by the service's `passfile=`. ~/.pgpass is never touched.
--
-- Output never contains URLs or passwords: only connection names and short reasons.

local uv = vim.uv

local config_home = vim.env.XDG_CONFIG_HOME
if not config_home or config_home == '' then config_home = vim.env.HOME .. '/.config' end
local connections_path = config_home .. '/dadbod/connections.yaml'
local pgpass_dir = config_home .. '/dadbod/pgpass.d'
local service_path = vim.env.PGSERVICEFILE
if not service_path or service_path == '' then service_path = vim.env.HOME .. '/.pg_service.conf' end

local BEGIN, END = '# BEGIN dadbod (generated from connections.yaml, do not edit)', '# END dadbod'
local RW_MARK = '# dadbod: read-write' -- read by pgro
local READ_ONLY = '-c default_transaction_read_only=on -c statement_timeout=60s -c lock_timeout=5s'
  .. ' -c idle_in_transaction_session_timeout=60s'
-- Connection parameters a URL may not override: they would bypass the read-only setup
local FORBIDDEN_PARAMS = { service = true, passfile = true, password = true, servicefile = true }

local function decode(s)
  return (s:gsub('%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end))
end

-- pgpass fields escape ':' and '\'
local function pgpass_escape(s) return (s:gsub('[\\:]', '\\%0')) end

-- Parse a postgres URL. Returns a table or nil, reason (reason never contains URL parts).
local function parse_url(url)
  local rest = url:match '^postgresql://(.*)$' or url:match '^postgres://(.*)$'
  if not rest then return nil, 'not a postgres:// URL' end
  local query = rest:match '%?(.*)$' or ''
  rest = rest:gsub('%?.*$', '')
  local authority, path = rest:match '^([^/]*)/?(.*)$'
  if select(2, authority:gsub('@', '')) > 1 then return nil, 'unencoded "@" in user or password' end
  local userinfo, hostport = authority:match '^(.*)@(.*)$'
  if not userinfo then hostport = authority end
  local c = { params = {} }
  if userinfo then
    local user, password = userinfo:match '^([^:]*):(.*)$'
    c.user = decode(user or userinfo)
    c.password = password and decode(password) or nil
  end
  if hostport:find(',', 1, true) then return nil, 'multiple hosts are not supported' end
  local host, port = hostport:match '^%[(.-)%]:?(%d*)$' -- [ipv6]:port
  if not host then host, port = hostport:match '^([^:]*):?(%d*)$' end
  if not host then return nil, 'cannot parse host/port' end
  c.host = decode(host)
  c.port = port ~= '' and port or '5432'
  if path == '{{dbname}}' then
    c.template = true
  elseif path ~= '' then
    if path:find('{{', 1, true) then return nil, 'unsupported placeholder in database' end
    c.dbname = decode(path)
  end
  for pair in query:gmatch '[^&]+' do
    local k, v = pair:match '^([^=]+)=(.*)$'
    if not k then return nil, 'cannot parse URL parameters' end
    k, v = decode(k), decode(v)
    if FORBIDDEN_PARAMS[k] then return nil, 'parameter "' .. k .. '" not allowed' end
    if k == 'host' or k == 'port' or k == 'user' or k == 'dbname' then
      return nil, 'parameter "' .. k .. '" not supported, put it in the URL itself'
    end
    if k:find '[^%w_]' or v:find '[\r\n]' then return nil, 'invalid URL parameter' end
    c.params[#c.params + 1] = { k, v }
  end
  if c.host == '' then return nil, 'no host (unix sockets are not supported)' end
  -- a newline would inject lines (even markers) into the service or pgpass file
  for _, v in ipairs { c.host, c.user or '', c.dbname or '', c.password or '' } do
    if v:find '[\r\n]' then return nil, 'invalid characters' end
  end
  if not c.user or c.user == '' then c.user = vim.env.USER end
  return c
end

local KUBE_TYPES = { svc = true, service = true, pod = true, deploy = true, deployment = true, sts = true, statefulset = true }
local LOCALHOST = { localhost = true, ['127.0.0.1'] = true, ['::1'] = true }

-- Check a connection's `tunnel:` against its parsed URL. Returns the marker line, or nil, reason.
local function tunnel_marker(t, c)
  local ns, kind, res, rport = t.kube:match '^([%l%d][%l%d.-]*)/(%l+)/([%l%d][%l%d.-]*):?(%d*)$'
  if not ns or not KUBE_TYPES[kind] then return nil, 'tunnel.kube must be <ns>/<svc|pod|deploy|sts>/<name>[:<port>]' end
  if rport == '' then rport = '5432' end
  if tonumber(rport) > 65535 then return nil, 'invalid tunnel.kube port' end
  if not t.context:match '^[%w][%w_.:@/-]*$' then return nil, 'invalid tunnel.context' end
  if not LOCALHOST[c.host] then return nil, 'a tunnel needs a localhost URL' end
  if c.port == '5432' then return nil, 'a tunnel cannot use local port 5432 (the local server)' end
  return table.concat({ '# dadbod: tunnel kube', t.context, ns, kind .. '/' .. res, c.port, rport }, ' ')
end

-- Check one connections.yaml value: a URL string or a mapping. Returns { url, rw, tunnel } or nil, reason.
local function check_entry(v)
  if type(v) == 'string' then return { url = v } end
  if type(v) ~= 'table' or vim.islist(v) then return nil, 'must be a URL or a mapping with url:' end
  for k in pairs(v) do
    if k ~= 'url' and k ~= 'rw' and k ~= 'tunnel' then return nil, 'unknown key "' .. k .. '"' end
  end
  if type(v.url) ~= 'string' then return nil, 'url: missing or not a string' end
  if v.rw ~= nil and type(v.rw) ~= 'boolean' then return nil, 'rw: must be true or false' end
  local t = v.tunnel
  if t ~= nil then
    if type(t) ~= 'table' or vim.islist(t) then return nil, 'tunnel: must be a mapping' end
    for k in pairs(t) do
      if k ~= 'kube' and k ~= 'context' then return nil, 'unknown key "tunnel.' .. k .. '"' end
    end
    if type(t.kube) ~= 'string' or type(t.context) ~= 'string' then
      return nil, 'tunnel: needs kube: and context:'
    end
  end
  return v
end

-- The connections as a list of { key = name, value = ... } in file order, or nil, reason
local function load_entries(path, lines)
  -- the old one-line format kept `# rw` / `kube=` tags in comments, which YAML drops
  for _, line in ipairs(lines) do
    local tags = line:match '^[^%s#][^%s:]*:%s*%S.-%s#(.*)$'
    if tags and ((' ' .. tags .. ' '):find '%srw%s' or tags:find 'kube=') then
      return nil, 'connections.yaml still has "# rw" / "kube=" tags: convert it with scripts/dadbod_migrate.lua'
    end
  end
  if vim.fn.executable 'yq' == 0 then return nil, 'yq is not installed' end
  local res = vim.system({ 'yq', '-o=json', 'to_entries', path }, { text = true }):wait()
  if res.code ~= 0 then
    -- yq messages may quote the file: keep only the position
    local line = (res.stderr or ''):match 'L(%d+)' or (res.stderr or ''):match 'line (%d+)'
    return nil, 'cannot parse connections.yaml' .. (line and (' (line ' .. line .. ')') or '')
  end
  if vim.trim(res.stdout) == '' then return {} end -- empty or only comments
  local ok, entries = pcall(vim.json.decode, res.stdout)
  if not ok or type(entries) ~= 'table' then return nil, 'unexpected yq output' end
  return entries
end

local function read_lines(path)
  local f = io.open(path, 'r')
  if not f then return nil end
  local lines = {}
  for line in f:lines() do lines[#lines + 1] = (line:gsub('\r$', '')) end
  f:close()
  return lines
end

-- Write via a temp file in the same dir, created with mode 600, then rename over the target
local function write_atomic(path, content)
  path = uv.fs_realpath(path) or path -- keep symlinks pointing at the real file
  local tmp = path .. '.tmp' .. uv.os_getpid()
  local fd = assert(uv.fs_open(tmp, 'wx', tonumber('600', 8)))
  local ok = uv.fs_write(fd, content) == #content
  uv.fs_close(fd)
  if not ok or not uv.fs_rename(tmp, path) then
    uv.fs_unlink(tmp)
    error('could not write ' .. path)
  end
end

local function main()
  local lines = read_lines(connections_path)
  if not lines then
    io.stderr:write('dadbod sync: cannot read ' .. connections_path .. '\n')
    return 1
  end

  local entries, err = load_entries(connections_path, lines)
  if not entries then
    io.stderr:write('dadbod sync: ' .. err .. ' (nothing changed)\n')
    return 1
  end

  local services, passfiles, skipped, seen = {}, {}, {}, {}
  local tunnel_ports = {} -- local port -> marker of the first tunnel on it
  for _, e in ipairs(entries) do
    local name = e.key
    local c, reason, conf, marker
    if type(name) ~= 'string' then
      name, reason = tostring(name), 'the file must be a mapping of connection names'
    elseif not name:match '^[%w_.-]+$' then
      reason = 'name must only contain letters, digits, "_", "." or "-"'
    elseif seen[name] then
      reason = 'duplicate name'
    else
      conf, reason = check_entry(e.value)
      if conf then c, reason = parse_url(vim.trim(conf.url)) end
      if c and conf.tunnel then
        marker, reason = tunnel_marker(conf.tunnel, c)
        if marker and tunnel_ports[c.port] and tunnel_ports[c.port] ~= marker then
          marker, reason = nil, 'local port ' .. c.port .. ' is already used by a tunnel with another target'
        end
        if not marker then c = nil end
      end
    end
    seen[name] = true
    if not c then
      skipped[#skipped + 1] = name .. ': ' .. reason
    else
      local rw = conf.rw == true
      local options = rw and '' or READ_ONLY
      local s = { '[' .. name .. ']', 'host=' .. c.host, 'port=' .. c.port, 'user=' .. c.user }
      if rw then table.insert(s, 1, RW_MARK) end
      if marker then
        table.insert(s, 1, marker)
        tunnel_ports[c.port] = marker
      end
      if c.dbname then s[#s + 1] = 'dbname=' .. c.dbname end
      for _, kv in ipairs(c.params) do
        if kv[1] == 'options' then
          -- the URL's own options go first: for repeated settings the last -c wins
          options = vim.trim(kv[2] .. ' ' .. options)
        else
          s[#s + 1] = kv[1] .. '=' .. kv[2]
        end
      end
      if options ~= '' then s[#s + 1] = 'options=' .. options end
      if c.password then
        local passfile = pgpass_dir .. '/' .. name
        s[#s + 1] = 'passfile=' .. passfile
        -- the file belongs to this connection only: any database (`pgro -d other`)
        passfiles[name] = table.concat({
          pgpass_escape(c.host), c.port, '*', pgpass_escape(c.user), pgpass_escape(c.password),
        }, ':') .. '\n'
      end
      services[#services + 1] = table.concat(s, '\n')
    end
  end

  -- pgpass.d: one file per connection; drop files of removed/renamed connections
  vim.fn.mkdir(pgpass_dir, 'p', tonumber('700', 8))
  uv.fs_chmod(pgpass_dir, tonumber('700', 8))
  for name, content in pairs(passfiles) do write_atomic(pgpass_dir .. '/' .. name, content) end
  for name in vim.fs.dir(pgpass_dir) do
    -- leave temp files alone: they may belong to a sync running at the same time
    if not passfiles[name] and not name:find('%.tmp%d+$') then uv.fs_unlink(pgpass_dir .. '/' .. name) end
  end

  -- service file: replace only our block
  local kept, inside = {}, false
  for _, line in ipairs(read_lines(service_path) or {}) do
    if line:match '^# BEGIN dadbod' then
      inside = true
    elseif inside and line == END then
      inside = false
    elseif not inside then
      kept[#kept + 1] = line
    end
  end
  while #kept > 0 and kept[#kept] == '' do kept[#kept] = nil end
  if #kept > 0 then kept[#kept + 1] = '' end
  local block = { BEGIN, table.concat(services, '\n\n'), END }
  write_atomic(service_path, table.concat(kept, '\n') .. (#kept > 0 and '\n' or '') .. table.concat(block, '\n') .. '\n')

  io.stdout:write(('dadbod sync: %d connection(s) synced to %s\n'):format(#services, service_path))
  for _, s in ipairs(skipped) do io.stdout:write('  skipped ' .. s .. '\n') end
  return #skipped > 0 and 2 or 0
end

local ok, res = pcall(main)
if not ok then
  -- error text comes from our own messages/paths, never from connection data
  io.stderr:write('dadbod sync failed: ' .. tostring(res):gsub('^[^:]*:%d+: ', '') .. '\n')
  os.exit(1)
end
os.exit(res)
