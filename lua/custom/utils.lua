local M = {}

M.IsWsl = function()
  local s
  local f = assert(io.popen('uname -r', 'r'))
  s = assert(f:read '*a')
  f:close()
  s = string.lower(s)
  s = string.find(s, 'wsl')
  return s ~= nil
end

M.CopytoClipboardCallback = function(a)
  if a == 'char' then
    vim.fn.execute [[normal! `[v`]"+y]]
  elseif a == 'line' then
    vim.fn.execute [[normal! `[V`]"+y]]
  else
    vim.fn.execute [[normal! `[\<C-v>`]"+y]]
  end
  vim.fn.execute [[let @/=@+]]
end

M.SubstituteCallback = function(a)
  if a == 'char' then
    vim.fn.execute [[normal! `[v`]y]]
  elseif a == 'line' then
    vim.fn.execute [[normal! `[V`]y]]
  else
    vim.fn.execute [[normal! `[\<C-v>`]y]]
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[:%s/\V<C-r>"//g<Left><Left>]], true, false, true), 'm', true)
end

function M.FormatRangeCallback()
  local old_func = vim.go.operatorfunc
  _G.op_func_formatting = function()
    local opts = {
      range = {
        ['start'] = vim.api.nvim_buf_get_mark(0, '['),
        ['end'] = vim.api.nvim_buf_get_mark(0, ']'),
      },
    }
    vim.lsp.buf.format(opts)
    vim.go.operatorfunc = old_func
    _G.op_func_formatting = nil
  end
  vim.go.operatorfunc = 'v:lua.op_func_formatting'
end

function M.get_fd_command()
  local global_fdignore
  if vim.fn.has 'win32' == 1 then
    global_fdignore = vim.fn.expand '$HOME' .. '/AppData/Roaming/fd/ignore'
  else
    global_fdignore = vim.fn.expand '$HOME' .. '/.config/fd/ignore'
  end
  local f = io.open(global_fdignore, 'rb')
  local fd_cmd = { 'fd', '-IH' }
  if f then
    f:close()
    for line in io.lines(global_fdignore) do
      fd_cmd[#fd_cmd + 1] = '-E'
      fd_cmd[#fd_cmd + 1] = line
    end
  end
  return fd_cmd
end

return M
