local utils = require 'custom.utils'

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
