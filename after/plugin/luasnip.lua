require("luasnip.loaders.from_vscode").lazy_load()

vim.keymap.set('i', '<C-j>', [[luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<C-j>' ]], {silent=true, expr=true})
vim.keymap.set('i', '<C-k>', [[lua require'luasnip'.jump(-1)<Cr>]], {silent=true})

vim.keymap.set('s', '<C-j>', [[lua require('luasnip').jump(1)<Cr>]], {silent=true})
vim.keymap.set('s', '<C-k>', [[lua require('luasnip').jump(-1)<Cr>]], {silent=true})

-- For changing choices in choiceNodes (not strictly necessary for a basic setup).
vim.keymap.set('i', '<C-E>', [[luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>']], {silent=true, expr=true})
vim.keymap.set('s', '<C-E>', [[luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>']], {silent=true, expr=true})
