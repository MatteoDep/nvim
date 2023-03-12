require("toggleterm").setup({
  open_mapping = "<A-t>",
  terminal_mappings = true,
  insert_mappings = false,
  direction = 'float',
  close_on_exit = false,
})

vim.keymap.set('t', "<A-Space>", [[<C-\><C-n>]])
vim.keymap.set('t', "<A-Enter>", [[<C-\><C-n>]])
vim.keymap.set('v', "<A-t>", [[:ToggleTermSendVisualLines ]], {desc = "Send to terminal <number>"})

local Terminal  = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new(
  {
    cmd = "lazygit",
    count = 42,
    on_close = function (_)
      vim.cmd("checktime")
    end,
    close_on_exit = true,
  })

function LazygitToggle()
  lazygit:toggle()
end

vim.api.nvim_set_keymap("n", "<A-g>", "<cmd>lua LazygitToggle()<CR>", {noremap = true, silent = true})
