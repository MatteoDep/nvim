-- [[ Setting options ]]
-- See `:help vim.o`

-- Set relative numbers
vim.opt.relativenumber = true

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- highlight cursor line
vim.o.cursorline = true

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250

-- enable sign column
vim.o.signcolumn = 'yes'

-- Set colorscheme
vim.o.termguicolors = true
vim.cmd("colorscheme onedark")

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Set folding method to treesitter
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 0

-- Set shell
vim.o.shell = "pwsh.exe"
vim.o.shellxquote = ""
vim.o.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command '
vim.o.shellquote = ''
vim.o.shellpipe = '| Out-File -Encoding UTF8 %s'
vim.o.shellredir = '| Out-File -Encoding UTF8 %s'

-- highlight search
vim.o.hlsearch = true
