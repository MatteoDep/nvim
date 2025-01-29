-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
  vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'

  use { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    requires = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',

      -- Additional lua configuration, makes nvim stuff amazing
      'folke/neodev.nvim',
    },
  }
  use 'nvimtools/none-ls.nvim'

  use { -- Autocompletion
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
    },
  }

  -- luasnip
  use({
	"L3MON4D3/LuaSnip",
	-- follow latest release.
	tag = "v2.*",
	-- install jsregexp (optional!:).
	run = "make install_jsregexp"
  })

  use {
    'saadparwaiz1/cmp_luasnip',
    requires = { 'L3MON4D3/LuaSnip' },
  }

  use { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
  }

  use { -- Additional text objects via treesitter
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = 'nvim-treesitter',
  }

  use {
    "rcarriga/nvim-dap-ui",
    requires = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"}
  }
  use 'theHamsta/nvim-dap-virtual-text'

  -- Git related plugins
  use 'tpope/vim-fugitive'
  use 'lewis6991/gitsigns.nvim'

  -- style
  use 'navarasu/onedark.nvim' -- Theme inspired by Atom
  use { "catppuccin/nvim", as = "catppuccin" }
  use 'nvim-lualine/lualine.nvim' -- Fancier statusline

  -- files tree
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
    tag = 'nightly' -- optional, updated every week. (see issue #1193)
  }

  -- commenting with `gc`
  use 'numToStr/Comment.nvim'

  -- automatic tab setting
  use 'tpope/vim-sleuth'

  -- Fuzzy Finder (files, lsp, etc)
  use { 'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = { 'nvim-lua/plenary.nvim' } }
  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }

  -- db integration
  use {
    'kristijanhusak/vim-dadbod-ui',
    requires = { 'tpope/vim-dadbod', 'kristijanhusak/vim-dadbod-completion' }
  }

  -- Which-key
  use({
    "folke/which-key.nvim",
    config = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
        require("which-key").setup({})
      end
  })

  -- surround motion
  use {
    "tpope/vim-surround",
    requires = { "tpope/vim-repeat" }
  }

  -- undotree
  use "mbbill/undotree"

  -- toggleterm
  use {"akinsho/toggleterm.nvim", tag = '*'}

  use "rafamadriz/friendly-snippets"

  use "godlygeek/tabular"

  use "tpope/vim-obsession"

  -- custom syntax
  use 'towolf/vim-helm'

  if is_bootstrap then
    require('packer').sync()
  end
end
)

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end
