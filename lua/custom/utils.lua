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

M.RunOutsideWindow = function(cmd)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())
  vim.cmd 'keepjumps close'
  vim.cmd('keepjumps buffer ' .. bufnr)
  vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), cursor_pos)
  vim.cmd('keepjumps normal! ' .. cmd)
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

return M
