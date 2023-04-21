require("luasnip.loaders.from_vscode").lazy_load()
local luasnip = require 'luasnip'

vim.keymap.set({'i', 's'}, '<C-j>', function ()
  if luasnip.expandable() then
    luasnip.expand()
  elseif luasnip.jumpable() then
    luasnip.jump(1)
  end
end, {silent=true})
vim.keymap.set({'i', 's'}, '<C-k>', function () luasnip.jump(-1) end, {silent=true})

-- For changing choices in choiceNodes (not strictly necessary for a basic setup).
vim.keymap.set({'i', 's'}, '<C-l>', function ()
  if luasnip.choice_active() then
    luasnip.next_choice()
  end
end, {silent=true, expr=true})
