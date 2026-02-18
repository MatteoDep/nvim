vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- enable nerd font icons
vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

local utils = require 'utils'

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

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  -- Can switch between these as you prefer
  virtual_text = false, -- Text shows up at the end of the line
  virtual_lines = true, -- Teest shows up underneath the line, with virtual lines
  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}
vim.keymap.set('n', '<leader>d', function() vim.diagnostic.open_float { scope = 'line' } end)

vim.keymap.set('t', '<A-[>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

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

-- swap lines
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '>-2<CR>gv=gv")

-- keep the middle
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- pasting without changing register
vim.keymap.set('x', 'gp', [["_c<C-r>"<Esc>]])

-- substitute with motion
vim.keymap.set('n', 'gs', [[<cmd>set opfunc=v:lua.require'utils'.SubstituteCallback<CR>g@]], { desc = 'Substitute' })
vim.keymap.set('n', 'gss', [[yy:%s/\V<C-r>"//g<Left><Left>]], { desc = 'Substitute' })
vim.keymap.set('v', 'gs', [[y:%s/\V<C-r>"//g<Left><Left>]], { desc = 'Substitute' })

-- system clipboard
vim.keymap.set('n', '<leader>y', [[<cmd>set opfunc=v:lua.require'utils'.CopytoClipboardCallback<CR>g@]], { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>yy', [["+yy]], { desc = 'Yank to system clipboard' })
vim.keymap.set('v', '<leader>y', [["+y]], { desc = 'Yank to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>p', [["+p]], { desc = 'Paste system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>P', [["+P]], { desc = 'Paste system clipboard' })

-- go to file
vim.keymap.set({ 'n', 'v' }, 'gf', 'gfzz', { desc = 'Go to file' })
vim.keymap.set({ 'n', 'v' }, 'gF', 'gFzz', { desc = 'Go to file:line' })
