local M = {}

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
M.colorscheme = "onedark"
M.theme = "dark"
M.lualine_theme = "one"..M.theme

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Set folding method to treesitter
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 1000

local iswsl = function()
  local s
  local f = assert(io.popen("uname -r", "r"))
  s = assert(f:read("*a"))
  f:close()
  s = string.lower(s)
  s = string.find(s, "wsl")
  return s ~= nil
end

-- Set shell
if vim.fn.has("win32") == 1 then
  vim.o.shell = [["C:\Program Files\Git\usr\bin\bash.exe"]]
  vim.o.shellcmdflag = '-c'
  vim.o.shellquote = ''
  vim.o.shellxescape = '"'
  vim.o.shellxquote = ''
  vim.o.shellredir = '>%s 2>&1'
  vim.o.shellpipe = '2>&1 | tee'
elseif iswsl() then
  vim.cmd([[
    let g:clipboard = {
                \   'name': 'WslClipboard',
                \   'copy': {
                \      '+': '/mnt/c/Windows/System32/clip.exe',
                \      '*': '/mnt/c/Windows/System32/clip.exe',
                \    },
                \   'paste': {
                \      '+': '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                \      '*': '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                \   },
                \   'cache_enabled': 0,
                \ }
  ]])
end

-- highlight search
vim.o.hlsearch = true

-- line and column in files
vim.cmd("set isfname-=:")

return M
