local map = vim.keymap.set
local opts = { noremap=true, silent=true }
local opts_nosilent = { noremap=true }

-- general options
require('general')

-- Lsp
require('lsp')

-- completion
require('completion')

-- TreeSitter
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = 'all',
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  rainbow = {
    enable = true,
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
  }
}
map('n', "<F3>", "<cmd>TSToggle highlight<CR>", opts_nosilent)

-- harpoon
require("harpoon").setup({
  menu = {
    width = math.floor(vim.api.nvim_win_get_width(0) / 3),
  },
})

local function harpoon_add(bufname)
  if bufname == "" or bufname == nil then
    return
  end
  local exclude = { 'harpoon', 'term://', 'undotree', 'diffpanel' }
  for _, substring in pairs(exclude) do
    if string.find(bufname, substring) then
      return
    end
  end
  local function f()
    require('harpoon.mark').add_file(bufname)
  end
  pcall(f)
end

vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter" }, {
  callback = function() harpoon_add(vim.fn.expand('<afile>')) end,
})

map('n', "<A-Tab>", function() require('harpoon.ui').nav_next() end, opts)
map('n', "<S-Tab>", function() require('harpoon.ui').nav_prev() end, opts)
map('n', "<A-h>", function() require('harpoon.ui').toggle_quick_menu() end, opts)
map('n', "<A-n>", function() harpoon_add(vim.fn.expand('%')) end, opts_nosilent)
for i = 1,9,1 do
  local si = string.format('%d', i)
  map('n', "<A-"..si..">", function() require('harpoon.ui').nav_file(i) end, opts)
end

-- floaterm
-- bg jobs
vim.g.floaterm_opener = 'edit'
map('n', "<Space>c", "<cmd>w<CR><cmd>FloatermSend compile %<CR>", opts)
map('n', "<Space>C", "<cmd>w<CR><cmd>FloatermSend compile --onlythis %<CR>", opts)

-- commands
map('n', "<A-e>", "<cmd>FloatermNew ranger --cmd='set preview_images=false'<CR>", opts)
map('n', "<A-f>", "<cmd>FloatermNew fzf -m<CR>", opts)
map('n', "<A-g>", "<cmd>FloatermNew lazygit<CR>", opts)
map('v', "<A-r>", [[y:FloatermNew rg '<C-R>=escape(@",'/\')<CR>'<CR>]], opts)
map('n', "<A-r>", [[yiw:FloatermNew rg '<C-R>"'<CR>]], opts)

-- interactive
map({'n', 't'}, "<A-t>", "<cmd>FloatermToggle<CR>", opts)
map('t', "<A-space>", "<C-\\><C-n>", opts)
map('t', "<A-n>", "<C-\\><C-n><cmd>FloatermNew<CR>", opts)
map('t', "<A-Tab>", "<C-\\><C-n><cmd>FloatermNext<CR>", opts)


-- Startup
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function ()
    vim.cmd("FloatermNew --silent")
    local argc = vim.fn.argc()
    if argc == 0 then
      require('harpoon.ui').toggle_quick_menu()
    else
      for i = 0,argc-1,1 do
        harpoon_add(vim.fn.argv(i))
      end
    end
  end
})

-- undo tree
map('n', "<F5>", "<cmd>UndotreeToggle<CR>", opts)
map('n', "U", "<cmd>UndotreeShow<CR><cmd>UndotreeFocus<CR>", opts)
vim.g.undotree_WindowLayout = 3

-- hexokinase
vim.g.Hexokinase_highlighters = { 'backgroundfull' }
vim.g.Hexokinase_ftEnabled = { 'css', 'html', 'javascript' }

