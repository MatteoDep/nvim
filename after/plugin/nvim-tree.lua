-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local function my_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- custom mappings
  vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Up'))
  vim.keymap.set('n', 'l', api.node.open.edit,  opts('Help'))
end

-- pass to setup along with your other options
require("nvim-tree").setup {
  ---
  ---
}

-- OR setup with some options
require("nvim-tree").setup({
    hijack_cursor = true,
    sync_root_with_cwd = true,
    on_attach = my_on_attach,
    renderer = {
        group_empty = true,
    },
    diagnostics = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = true,
    },
    modified = {
        enable = true,
    },
    git = {
        enable = true,
        ignore = false,
        show_on_dirs = true,
        show_on_open_dirs = true,
        timeout = 400,
    },
})

vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeToggle, {desc = "[E]xplore with nvim-tree"})

-- Automatically close nvim-tree if it is the last buffer
-- nvim-tree is also there in modified buffers so this function filter it out
local modifiedBufs = function(bufs)
    local t = 0
    for _, v in pairs(bufs) do
        if v.name:match("NvimTree_") == nil then
            t = t + 1
        end
    end
    return t
end

vim.api.nvim_create_autocmd("BufEnter", {
    nested = true,
    callback = function()
        if #vim.api.nvim_list_wins() == 1 and
        vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil and
        modifiedBufs(vim.fn.getbufinfo({bufmodified = 1})) == 0 then
            vim.cmd "quit"
        end
    end
})
