-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- OR setup with some options
require("nvim-tree").setup({
    hijack_cursor = true,
    sync_root_with_cwd = true,
    view = {
    mappings = {
        list = {
            { key='h', action='close_node' },
            { key='l', action='edit' },
        },
    },
    },
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
