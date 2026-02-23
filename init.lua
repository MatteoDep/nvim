require 'settings'

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  -- NOTE: Plugins can be added via a link or github org/name. To run setup automatically, use `opts = {}`
  { 'NMAC427/guess-indent.nvim', opts = {} },

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
    },
  },

  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      -- picker = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      bufdelete = { enabled = true },
      terminal = { enabled = true },
    },
    keys = {
      { '<A-g>', function() Snacks.lazygit() end, desc = 'Lazygit', mode = { 'n', 't' } },
      { '<leader>z', function() Snacks.zen() end, desc = 'Toggle Zen Mode' },
      { '<leader>Z', function() Snacks.zen.zoom() end, desc = 'Toggle Zoom' },
      { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer' },
      { '<leader>S', function() Snacks.scratch.select() end, desc = 'Select Scratch Buffer' },
      { '<leader>n', function() Snacks.notifier.show_history() end, desc = 'Notification History' },
      { 'XX', function() Snacks.bufdelete() end, desc = 'Delete Buffer' },
      { '<leader>rn', function() Snacks.rename.rename_file() end, desc = 'Rename File' },
      { '<A-t>', function() Snacks.terminal.toggle(nil, { auto_insert = false }) end, desc = 'Toggle Terminal', mode = { 'n', 't' } },
    },
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Create some toggle mappings
          Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>ts'
          Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>tw'
          Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>tl'
          Snacks.toggle.diagnostics():map '<leader>td'
          Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>tc'
          Snacks.toggle.treesitter():map '<leader>tT'
          Snacks.toggle.inlay_hints():map '<leader>th'
          Snacks.toggle.indent():map '<leader>tg'
          Snacks.toggle.dim():map '<leader>tD'
        end,
      })
    end,
  },

  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    -- or if using mini.icons/mini.nvim
    -- dependencies = { "nvim-mini/mini.icons" },
    ---@module "fzf-lua"
    ---@type fzf-lua.Config|{}
    ---@diagnostic disable: missing-fields
    opts = {},
    ---@diagnostic enable: missing-fields
    config = function()
      require 'fzf-lua'
      FzfLua.register_ui_select()

      vim.keymap.set('n', '<leader><space>', FzfLua.builtin, { desc = 'fzf-lua builtin' })
      vim.keymap.set('n', '<leader>s.', FzfLua.builtin, { desc = 'fzf-lua builtin' })

      -- files & buffers
      vim.keymap.set('n', '<leader>sf', FzfLua.files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>sF', FzfLua.git_files, { desc = 'Find Git Files' })
      vim.keymap.set('n', '<leader>sb', FzfLua.blines, { desc = 'Buffer Lines' })
      vim.keymap.set('n', '<leader>sB', FzfLua.lines, { desc = 'Grep Open Buffers' })

      -- grep
      vim.keymap.set('n', '<leader>sg', FzfLua.live_grep, { desc = 'Grep' })
      vim.keymap.set('n', '<leader>sw', FzfLua.grep_cword, { desc = 'Grep word under cursor' })
      vim.keymap.set('x', '<leader>sw', FzfLua.grep_visual, { desc = 'Grep visual selection' })

      -- history & misc
      vim.keymap.set('n', '<leader>:', FzfLua.command_history, { desc = 'Command History' })
      vim.keymap.set('n', '<leader>s/', FzfLua.search_history, { desc = 'Search History' })
      vim.keymap.set('n', '<leader>sd', FzfLua.diagnostics_workspace, { desc = 'Diagnostics' })
      vim.keymap.set('n', '<leader>sD', FzfLua.diagnostics_document, { desc = 'Buffer Diagnostics' })
      vim.keymap.set('n', '<leader>sh', FzfLua.helptags, { desc = 'Help Pages' })
      vim.keymap.set('n', '<leader>sk', FzfLua.keymaps, { desc = 'Keymaps' })
      vim.keymap.set('n', '<leader>sM', FzfLua.manpages, { desc = 'Man Pages' })
      vim.keymap.set('n', '<leader>sq', FzfLua.quickfix, { desc = 'Quickfix List' })
      vim.keymap.set('n', '<leader>sR', FzfLua.resume, { desc = 'Resume' })

      -- git
      vim.keymap.set('n', '<leader>gb', FzfLua.git_branches, { desc = 'Git Branches' })
      vim.keymap.set('n', '<leader>gl', FzfLua.git_commits, { desc = 'Git Log' })
      vim.keymap.set('n', '<leader>gL', FzfLua.git_bcommits, { desc = 'Git Log Line' })
      vim.keymap.set('n', '<leader>gs', FzfLua.git_status, { desc = 'Git Status' })
      vim.keymap.set('n', '<leader>gS', FzfLua.git_stash, { desc = 'Git Stash' })
      vim.keymap.set('n', '<leader>gf', FzfLua.git_bcommits, { desc = 'Git Log File' })

      -- lsp
      vim.keymap.set('n', 'gd', FzfLua.lsp_definitions, { desc = '[g]oto [d]efinition' })
      vim.keymap.set('n', 'gD', FzfLua.lsp_declarations, { desc = '[g]oto [d]eclaration' })
      vim.keymap.set('n', 'gI', FzfLua.lsp_implementations, { desc = '[g]oto [i]mplementation' })
      vim.keymap.set('n', 'gy', FzfLua.lsp_typedefs, { desc = '[g]oto t[y]pe definition' })
      vim.keymap.set('n', 'grr', FzfLua.lsp_references, { desc = '[g]oto [r]eferences' })
      vim.keymap.set('n', '<leader>ss', FzfLua.lsp_document_symbols, { desc = 'lsp symbols' })
      vim.keymap.set('n', '<leader>sS', FzfLua.lsp_workspace_symbols, { desc = 'lsp workspace symbols' })
      vim.keymap.set({ 'n', 'x' }, 'gra', FzfLua.lsp_code_actions, { desc = '[g]oto Code [a]ction' })
    end,
  },

  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    config = true,
    keys = {
      { '<leader>a', nil, desc = 'AI/Claude Code' },
      { '<A-c>', '<cmd>ClaudeCode<cr>', mode = { 'n', 't' }, desc = 'Toggle Claude' },
      { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
      { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
      { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
      { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
      { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
      {
        '<leader>as',
        '<cmd>ClaudeCodeTreeAdd<cr>',
        desc = 'Add file',
        ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
      },
      -- Diff management
      { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
      { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
    },
  },

  -- LSP Plugins
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      { -- optional saghen/blink.cmp completion source
        'saghen/blink.cmp',
        opts = {
          sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
            per_filetype = {
              sql = { 'snippets', 'dadbod', 'buffer' },
            },
            -- add vim-dadbod-completion to your completion providers
            providers = {
              dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
            },
          },
        },
      },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          vim.keymap.set('n', 'grn', vim.lsp.buf.rename, { desc = '[r]e[n]ame' })

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end
        end,
      })

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        clangd = {},
        gopls = {},
        ruff = {
          init_options = {
            settings = {
              lineLength = 120,
            },
          },
        },
        ty = {},
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'lua-language-server', -- Lua Language server
        'stylua', -- Used to format Lua code
        -- You can add other tools here that you want Mason to install
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for name, server in pairs(servers) do
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end

      -- Special Lua Config, as recommended by neovim help docs
      vim.lsp.config('lua_ls', {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT',
              path = { 'lua/?.lua', 'lua/?/init.lua' },
            },
            workspace = {
              checkThirdParty = false,
              -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
              --  See https://github.com/neovim/nvim-lspconfig/issues/3189
              library = vim.api.nvim_get_runtime_file('', true),
            },
          })
        end,
        settings = {
          Lua = {},
        },
      })
      vim.lsp.enable 'lua_ls'
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = false,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = {
          'ruff_fix',
          'ruff_format',
          'ruff_organize_imports',
        },
      },
    },
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
          },
        },
        opts = {},
      },
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
      },

      appearance = {
        nerd_font_variant = 'mono',
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },

  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'nvim-mini/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
      require('mini.align').setup()
      require('mini.tabline').setup()
      require('mini.files').setup {
        mappings = {
          go_in = '<CR>',
          go_out = '<BS>',
          reset = 'g<BS>',
        },
        windows = {
          preview = true,
        },
      }

      vim.keymap.set('n', '<leader>e', MiniFiles.open, { desc = 'Open MiniFiles' })
      vim.keymap.set('n', '<leader>E', function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = 'Open MiniFiles on current buffer location' })

      -- Yank in register full path of entry under cursor
      local yank_path = function()
        local path = (MiniFiles.get_fs_entry() or {}).path
        if path == nil then return vim.notify 'Cursor is not on valid entry' end
        vim.fn.setreg(vim.v.register, path)
      end

      -- Open path with system default handler (useful for non-text files)
      local ui_open = function() vim.ui.open(MiniFiles.get_fs_entry().path) end
      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local b = args.data.buf_id
          vim.keymap.set('n', 'gx', ui_open, { buffer = b, desc = 'OS open' })
          vim.keymap.set('n', 'gy', yank_path, { buffer = b, desc = 'Yank path' })
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesActionRename',
        callback = function(event) Snacks.rename.on_rename_file(event.data.from, event.data.to) end,
      })
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    opts = {
      ensure_installed = {},
      auto_install = true, -- Autoinstall languages that are not installed
      highlight = { enable = true },
      indent = { enable = true },
      textobjects = { enable = true },
    },
  },

  { import = 'plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
