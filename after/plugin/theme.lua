-- theme settings
local settings = require('mdp.set')

vim.o.termguicolors = true
vim.o.background = settings.theme

if settings.colorscheme == 'onedark' then
    local onedark = require('onedark')

    onedark.setup  {
        style = settings.theme,
        transparent = false,
    }
    onedark.load()
else
    vim.cmd('colorscheme '..settings.colorscheme)
end

-- lualine
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = settings.lualine_theme,
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {
      {
        'branch',
        draw_empty = true,
      },
      'diff',
      {
        'diagnostics',
        icons_enabled = false,
      },
    },
    lualine_c = {
      {
        'filename',
        path = 1,
      },
    },
    lualine_x = {
      'encoding',
      'fileformat',
      'filetype',
    },
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {
    lualine_a = {
      {
        'buffers',
        mode=2,
        max_length = vim.o.columns * 9 / 10,
        symbols = {
          modified = ' ',      -- Text to show when the buffer is modified
          alternate_file = '# ', -- Text to show to identify the alternate file
          directory =  ' ',     -- Text to show when the buffer is a directory
        },
      },
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'tabs' },
  },
}
