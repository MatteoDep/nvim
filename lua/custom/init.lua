local utils = require 'custom.utils'

-- Set folding method to treesitter
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldlevel = 1000

-- gui
if vim.g.neovide then
  vim.g.neovide_scale_factor = 0.7
end

-- Set shell
if vim.fn.has 'win32' == 1 then
  vim.o.shell = [["C:\Program Files\Git\bin\bash.exe"]]
  vim.o.shellcmdflag = '-c'
  vim.o.shellquote = ''
  vim.o.shellxescape = '"'
  vim.o.shellxquote = ''
  vim.o.shellredir = '>%s 2>&1'
  vim.o.shellpipe = '2>&1 | tee'
elseif utils.IsWsl() then
  vim.g.clipboard = {
    name = 'wsl clipboard',
    copy = { ['+'] = { 'winclip' }, ['*'] = { 'winclip' } },
    paste = { ['+'] = { 'winclip', '-o' }, ['*'] = { 'winclip', '-o' } },
    cache_enabled = true,
  }
end

-- add filetypes
vim.filetype.add {
  extension = {
    templ = 'templ',
  },
}

-- KEYMAPS

-- Remap for dealing with line wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- windows
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<A-->', '<C-w>-')
vim.keymap.set('n', '<A-=>', '<C-w>+')
vim.keymap.set('n', '<A-,>', '<C-w><')
vim.keymap.set('n', '<A-.>', '<C-w>>')

-- quickfix or buffer navigation
local GetSwitchQuickfixOrBuffer = function(dir)
  return function()
    if vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), 'v:val.quickfix')) > 0 then
      vim.cmd('b' .. dir)
    else
      vim.cmd('c' .. dir)
    end
  end
end
vim.keymap.set('n', '<C-n>', GetSwitchQuickfixOrBuffer 'next')
vim.keymap.set('n', '<C-p>', GetSwitchQuickfixOrBuffer 'prev')

-- quickfix
local ToggleQuickfix = function()
  if vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), 'v:val.quickfix')) > 0 then
    vim.cmd 'copen'
  else
    vim.cmd 'cclose'
  end
end
vim.keymap.set('n', '<C-q>', ToggleQuickfix)

-- buffers
local function goto_buffer()
  if vim.v.count == 0 then
    vim.cmd 'bnext'
  else
    vim.cmd('LualineBuffersJump ' .. vim.v.count)
  end
  vim.cmd 'normal! zz'
end
vim.keymap.set('n', 'gb', goto_buffer, { desc = 'next/goto <count> [B]uffer' })
vim.keymap.set('n', 'gB', '<cmd>bprev<CR>zz', { desc = 'previous [B]uffer' })
vim.keymap.set('n', 'XX', '<cmd>bdel<CR>')
vim.keymap.set('n', 'XQ', '<cmd>bdel!<CR>')

-- swap lines
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '>-2<CR>gv=gv")

-- keep the middle
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- pasting without changing register
vim.keymap.set('x', 'gp', [["_c<C-r>"<Esc>]])

-- substitute with motion
vim.keymap.set('n', 'gs', [[<cmd>set opfunc=v:lua.require'custom.utils'.SubstituteCallback<CR>g@]], { desc = 'Substitute' })
vim.keymap.set('n', 'gss', [[yy:%s/\V<C-r>"//g<Left><Left>]], { desc = 'Substitute' })
vim.keymap.set('v', 'gs', [[y:%s/\V<C-r>"//g<Left><Left>]], { desc = 'Substitute' })

-- system clipboard
vim.keymap.set('n', '<leader>y', [[<cmd>set opfunc=v:lua.require'custom.utils'.CopytoClipboardCallback<CR>g@]], { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>yy', [["+yy]], { desc = 'Yank to system clipboard' })
vim.keymap.set('v', '<leader>y', [["+y]], { desc = 'Yank to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>p', [["+p]], { desc = 'Paste system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>P', [["+P]], { desc = 'Paste system clipboard' })

-- go to file
vim.keymap.set({ 'n', 'v' }, 'gf', 'gfzz', { desc = 'Go to file' })
vim.keymap.set({ 'n', 'v' }, 'gF', 'gFzz', { desc = 'Go to file:line' })
