-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')

-- Remap for dealing with line wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- move between windows
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- move between quickfix
vim.keymap.set('n', '<C-n>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-p>', '<cmd>cprev<CR>zz')
local ToggleQuickfix = function()
  if vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), 'v:val.quickfix')) > 0
  then
    vim.cmd('copen')
  else
    vim.cmd('cclose')
  end
end
vim.keymap.set('n', '<C-q>', ToggleQuickfix)

-- move between buffers
vim.keymap.set('n', 'gb', '<cmd>bnext<CR>zz')
vim.keymap.set('n', 'gB', '<cmd>bprev<CR>zz')
vim.keymap.set('n', 'ZX', '<cmd>bdel<CR>')

-- folding
vim.keymap.set('n', '<Space><Space>', 'za')
vim.keymap.set('n', '<Space><CR>', 'zA')

-- swap lines
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '>-2<CR>gv=gv")

-- keep the middle
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- stop highlight
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {desc = "diagnostic prevous"})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {desc = "diagnostic next"})
vim.keymap.set('n', '<leader>sd', require("telescope.builtin").diagnostics, { desc = '[S]earch [D]iagnostics' })

-- pasting without changing register
vim.keymap.set('x', 'gp', [["_dP]])

-- substitute with motion
local M = {}

M.CopytoClipboardCallback = function (_)
  vim.fn.execute([[normal! `[v`]"+y]])
  vim.fn.execute([[let @/=@+]])
end

M.SubstituteCallback = function (_)
  vim.fn.execute([[normal! `[v`]y]])
  vim.fn.execute([[let @/=@"]])
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(':%s/<C-r>"//g<Left><Left>', true, false, true), 'm', true)
end

vim.keymap.set({'n', 'v'}, 'gs',
  [[<cmd>set opfunc=v:lua.require'mdp.remap'.SubstituteCallback<CR>g@]],
  {desc="Substitute"}
)

-- system clipboard
vim.keymap.set({'n', 'v'}, '<leader>y',
  [[<cmd>set opfunc=v:lua.require'mdp.remap'.CopytoClipboardCallback<CR>g@]],
  {desc="Substitute"}
)
vim.keymap.set({ 'n', 'v' }, '<leader>p', [["+p]])
vim.keymap.set({ 'n', 'v' }, '<leader>P', [["+P]])

return M
