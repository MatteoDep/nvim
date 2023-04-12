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
    for _, cmd in ipairs({"gf", "gF"}) do
      vim.keymap.set("n", cmd, function ()
        require'mdp.util'.RunOutsideWindow(cmd)
      end, {noremap = true, silent = true, desc="run outside window '"..cmd.."'", buffer=0})
    end
  end,
})

vim.keymap.set('t', "<A-Space>", [[<C-\><C-n>]])
vim.keymap.set('t', "<A-Enter>", [[<C-\><C-n>]])
vim.keymap.set('v', "<A-t>", [[:ToggleTermSendVisualLines ]], {desc = "Send to terminal <number>"})

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
