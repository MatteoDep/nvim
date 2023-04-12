local M = {}


M.CopytoClipboardCallback = function (a)
  if a == "char" then
    vim.fn.execute([[normal! `[v`]"+y]])
  elseif a == "line" then
    vim.fn.execute([[normal! `[V`]"+y]])
  else
    vim.fn.execute([[normal! `[\<C-v>`]"+y]])
  end
  vim.fn.execute([[let @/=@+]])
end

M.SubstituteCallback = function (a)
  if a == "char" then
    vim.fn.execute([[normal! `[v`]y]])
  elseif a == "line" then
    vim.fn.execute([[normal! `[V`]y]])
  else
    vim.fn.execute([[normal! `[\<C-v>`]y]])
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[:%s/\V<C-r>"//g<Left><Left>]], true, false, true), 'm', true)
end

return M
