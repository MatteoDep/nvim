require("luasnip.loaders.from_vscode").lazy_load()

vim.keymap.set('i', '<silent><expr> <Tab>', [[luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' ]], {silent=true, expr=true})
vim.keymap.set('i', '<S-Tab>', [[lua require'luasnip'.jump(-1)<Cr>]], {silent=true})

vim.keymap.set('s', '<Tab>', [[lua require('luasnip').jump(1)<Cr>]], {silent=true})
vim.keymap.set('s', '<S-Tab>', [[lua require('luasnip').jump(-1)<Cr>]], {silent=true})

-- For changing choices in choiceNodes (not strictly necessary for a basic setup).
vim.keymap.set('i', '<silent><expr> <C-E>', [[luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>']], {silent=true, expr=true})
vim.keymap.set('s', '<silent><expr> <C-E>', [[luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>']], {silent=true, expr=true})
