local function myfocus()
  vim.cmd('UndotreeShow')
  vim.cmd('UndotreeFocus')
end

vim.keymap.set("n", "<leader>u", myfocus, {desc = "[U]ndotree"})
