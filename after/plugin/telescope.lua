local global_fdignore
if vim.fn.has("win32") == 1 then
  global_fdignore = vim.fn.expand("$HOME").."/AppData/Roaming/fd/ignore"
else
  global_fdignore = "~/.config/fd/ignore"
end
local f = io.open(global_fdignore, "rb")
local fd_cmd = { "fd", "-IH" }
if f then
  f:close()
  for line in io.lines(global_fdignore) do
    fd_cmd[#fd_cmd+1] = "-E"
    fd_cmd[#fd_cmd+1] = line
  end
end

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<C-h>'] = "which_key",
        ['<Tab>'] = "move_selection_previous",
        ['<S-Tab>'] = "move_selection_next",
      },
    },
    path_display = { "truncate" },
    theme = "dropdown",
  },
  pickers = {
    find_files = {
      find_command = fd_cmd,
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>/', function ()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Search in current buffer' })
vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[S]earch existing [B]uffers' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', builtin.git_files, { desc = '[S]earch [G]it files' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>se', builtin.live_grep, { desc = '[S]earch [E]xpression' })
