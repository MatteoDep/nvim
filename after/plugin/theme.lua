-- theme settings
local settings = require('mdp.set')

vim.o.termguicolors = true
vim.o.background = settings.theme

if settings.colorscheme == 'onedark' then
    local onedark = require('onedark')

    onedark.setup  {
        style = settings.theme,
        transparent = true,
    }
    onedark.load()
else
    vim.cmd('colorscheme '..settings.colorscheme)
end

-- lualine
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = settings.lualine_theme,
    component_separators = '|',
    section_separators = '',
  },
  winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {
    lualine_a = {
      {
        'buffers',
        max_length = vim.o.columns
      }
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'tabs' },
  }
}
