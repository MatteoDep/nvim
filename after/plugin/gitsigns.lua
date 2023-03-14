-- Gitsigns
-- See `:help gitsigns.txt`
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

vim.keymap.set('n', '<leader>gg', '<cmd>Gitsigns setqflist<CR>', {desc="[G]it changes qflist"})
vim.keymap.set('n', '<leader>gn', '<cmd>Gitsigns next_hunk<CR>', {desc="[G]it changes next"})
vim.keymap.set('n', '<leader>gp', '<cmd>Gitsigns prev_hunk<CR>', {desc="[G]it changes prev"})
