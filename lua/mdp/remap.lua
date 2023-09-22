vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')

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

-- quickfix
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

-- buffers
local function goto_buffer()
  if vim.v.count == 0 then
    vim.cmd("bnext")
    vim.cmd("normal! zz")
  else
    vim.cmd("LualineBuffersJump "..vim.v.count)
    vim.cmd("normal! zz")
  end
end
vim.keymap.set('n', 'gb', goto_buffer, {desc="next/goto <count> [B]uffer"})
vim.keymap.set('n', 'gB', '<cmd>bprev<CR>zz', {desc="previous [B]uffer"})
vim.keymap.set('n', '<A-n>', '<cmd>bnext<CR>zz', {desc="next/goto <count> [B]uffer"})
vim.keymap.set('n', '<A-p>', '<cmd>bprev<CR>zz', {desc="previous [B]uffer"})
for i = 0, 9, 1 do
  local key = (i % 10) + 1
  vim.keymap.set('n', '<A-'..key..'>', '<cmd>LualineBuffersJump '..key..'<CR>zz', {desc="previous [B]uffer"})
end

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
vim.keymap.set('x', 'gp', [["_c<C-r>"<Esc>]])

-- substitute with motion
vim.keymap.set('n', 'gs',
  [[<cmd>set opfunc=v:lua.require'mdp.util'.SubstituteCallback<CR>g@]],
  {desc="Substitute"}
)
vim.keymap.set('n', 'gss', [[yy:%s/\V<C-r>"//g<Left><Left>]], {desc="Substitute"})
vim.keymap.set('v', 'gs', [[y:%s/\V<C-r>"//g<Left><Left>]], {desc="Substitute"})

-- system clipboard
vim.keymap.set('n', '<leader>y',
  [[<cmd>set opfunc=v:lua.require'mdp.util'.CopytoClipboardCallback<CR>g@]],
  {desc="Yank to system clipboard"}
)
vim.keymap.set('n', '<leader>yy', [["+yy]], {desc="Yank to system clipboard"})
vim.keymap.set('v', '<leader>y', [["+y]], {desc="Yank to system clipboard"})
vim.keymap.set({ 'n', 'v' }, '<leader>p', [["+p]], {desc="Paste system clipboard"})
vim.keymap.set({ 'n', 'v' }, '<leader>P', [["+P]], {desc="Paste system clipboard"})

-- go to file
vim.keymap.set({ 'n', 'v' }, 'gf', 'gfzz', {desc="Go to file"})
vim.keymap.set({ 'n', 'v' }, 'gF', 'gFzz', {desc="Go to file:line"})

-- tabularize
for _, symbol in pairs({'=', '|'}) do
  vim.keymap.set({ 'n', 'v' }, '<leader>a'..symbol, '<cmd>Tab /'..symbol..'<CR>', {desc="[A]lign ("..symbol..")."})
end
for _, symbol in pairs({':'}) do
  vim.keymap.set({ 'n', 'v' }, '<leader>a'..symbol, '<cmd>Tab /'..symbol..'\zs<CR>', {desc="[A]lign ("..symbol..")."})
end
vim.keymap.set({ 'n', 'v' }, '<leader>aa', ':Tab /', {desc="[A]lign prompt."})
