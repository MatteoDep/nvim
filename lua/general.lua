local map = vim.keymap.set
local opts = { noremap=true, silent=true }

-- mouse
vim.opt.mouse = nil
map({'n', 'i'}, "<F2>", function() vim.opt.mouse = 'a' end, opts)

-- undo
local undodir = vim.fn.expand("$XDG_CACHE_HOME/nvim/undo")
os.execute('mkdir -p '..undodir)
vim.opt.undodir = undodir
vim.opt.undofile = true

-- theming
vim.cmd [[
  colorscheme custom
  hi Normal guibg=NONE ctermbg=NONE
]]
vim.opt.termguicolors = true
vim.g.webdevicons_enable_airline_statusline = 1
vim.g.airline_theme = 'custom'
vim.api.nvim_create_autocmd({ "Signal SIGUSR1" }, {
  callback = function ()
    vim.cmd [[
      colorscheme custom
      AirlineTheme custom
      hi Normal guibg=NONE ctermbg=NONE
      redraw!
      redrawtabline
    ]]
  end
})

vim.cmd [[
  syntax enable " fallback for treesitter
  filetype plugin on " enable filetype specific options
]]
vim.opt.completeopt = 'menu,menuone,noselect'                 -- completion style
vim.opt.shada:append({ n = '~/.config/nvim/main.shada' }) -- change viminfo location
vim.opt.hidden = true                                         -- To keep multiple buffers open
vim.opt.wrap = false                                          -- wrap long lines
vim.opt.encoding = 'utf-8'                                    -- The encoding displayed
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = false                                      -- don't highlight search
vim.opt.incsearch = true                                      -- incremental search
vim.opt.errorbells = false                                     -- disable sound error effects
vim.opt.spelllang = 'en_us,it'
vim.opt.nrformats = 'bin,hex,alpha'		   -- to use ctrl-a and ctrl-x
vim.opt.formatoptions = 'tcrvqlj'
-- tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = false
-- python support
vim.g.loaded_python_provider = 0
vim.g.python3_host_prog = '~/.config/nvim/nvim-pyenv/bin/python'
-- folding
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
