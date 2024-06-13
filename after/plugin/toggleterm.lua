local util = require 'mdp.util'
require("toggleterm").setup({
  open_mapping = "<A-t>",
  terminal_mappings = true,
  insert_mappings = false,
  direction = 'float',
  close_on_exit = true,
  start_in_insert = true,
  auto_scroll = false,
  persist_mode = true,
  on_close = function (_)
    vim.cmd("checktime")
  end,
  on_open = function (_)
    for cmd, desc in pairs({gf="Go to file", gF="Go to file:line"}) do
      vim.keymap.set('n', cmd, function ()
        util.RunOutsideWindow(cmd.."zz")
      end, {noremap = true, silent = true, desc=desc, buffer=0})
    end
  end,
  float_opts = {
    width = function ()
      return vim.o.columns - 2
    end,
    height = function ()
      return vim.o.lines - 3
    end,
    row = 0,
    border = "curved",
    winblend = 0,
  },
})

vim.keymap.set('t', "<A-[>", [[<C-\><C-n>]])
vim.keymap.set('v', "<Space>t", [[:ToggleTermSendVisualLines ]], {desc = "Send to terminal <number>"})

local Terminal  = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new(
  {
    cmd = "lazygit",
    hidden = true,
    on_close = function (_)
      vim.cmd("checktime")
    end,
    on_open = function (_)
      vim.cmd("startinsert")
    end,
    close_on_exit = true,
    start_in_insert = true,
  })

function LazygitToggle()
  lazygit:toggle()
end

vim.keymap.set({'n', 't'}, "<A-g>", "<cmd>lua LazygitToggle()<CR>", {noremap = true, silent = true})
