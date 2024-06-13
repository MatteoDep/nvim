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

vim.keymap.set('n', '<leader>gl', '<cmd>Gitsigns setqflist<CR>', {desc="[G]it changes qf[L]ist"})
vim.keymap.set('n', ']g', '<cmd>Gitsigns next_hunk<CR>', {desc="[G]it changes [N]ext"})
vim.keymap.set('n', '[g', '<cmd>Gitsigns prev_hunk<CR>', {desc="[G]it changes [P]rev"})
vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<CR>', {desc="[G]it [B]lame"})
vim.keymap.set('n', '<leader>gcb', ':Gitsigns change_base ', {desc="[G]it [C]hange [B]ase"})
vim.keymap.set('n', '<leader>gr', '<cmd>Gitsigns reset_hunk<CR>', {desc="[G]it [R]eset hunk"})
vim.keymap.set('n', '<leader>gd', '<cmd>Gitsigns diffthis<CR>', {desc="[G]it [D]iff current file"})
