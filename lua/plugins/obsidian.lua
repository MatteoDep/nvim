return {
  'epwalsh/obsidian.nvim',
  version = '*',
  lazy = true,
  ft = 'markdown',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    workspaces = {
      {
        name = 'notes',
        path = '/mnt/c/Users/MatteoDePellegrin/Notes',
      },
    },

    daily_notes = {
      folder = 'dailies',
      date_format = '%Y-%m-%d',
      alias_format = '%B %-d, %Y',
      default_tags = { 'daily-notes' },
    },

    -- blink.cmp not supported, disable nvim-cmp integration
    completion = {
      nvim_cmp = false,
      min_chars = 2,
    },

    mappings = {
      ['gf'] = {
        action = function()
          return require('obsidian').util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      ['<leader>ch'] = {
        action = function()
          return require('obsidian').util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
      ['<cr>'] = {
        action = function()
          return require('obsidian').util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },

    new_notes_location = 'current_dir',

    note_id_func = function(title)
      if title ~= nil then
        return title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
      end
      local suffix = ''
      for _ = 1, 4 do
        suffix = suffix .. string.char(math.random(65, 90))
      end
      return tostring(os.time()) .. '-' .. suffix
    end,

    preferred_link_style = 'wiki',

    templates = {
      folder = 'templates',
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
    },

    follow_url_func = function(url)
      vim.ui.open(url)
    end,

    follow_img_func = function(img)
      vim.ui.open(img)
    end,

    picker = {
      name = 'fzf-lua',
      note_mappings = {
        new = '<C-x>',
        insert_link = '<C-l>',
      },
      tag_mappings = {
        tag_note = '<C-x>',
        insert_tag = '<C-l>',
      },
    },

    sort_by = 'modified',
    sort_reversed = true,

    -- UI handled by render-markdown.nvim
    ui = { enable = false },
  },
}
