-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- remove trailing spaces
local format_trailing = vim.api.nvim_create_augroup('FormatTrailing', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function ()
    vim.o.hlsearch = false
    vim.cmd([[%s/\s*$//]])
    vim.o.hlsearch = true
  end,
  group = format_trailing,
  pattern = '*',
})
