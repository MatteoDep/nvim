local map = vim.keymap.set
-- Lsp mappings
local opts = { noremap=true, silent=true }
map('n', '<space>e', function() vim.diagnostic.open_float() end, opts)
map('n', '[d', function() vim.diagnostic.goto_prev() end, opts)
map('n', ']d', function() vim.diagnostic.goto_next() end, opts)
map('n', '<space>q', function() vim.diagnostic.setloclist() end, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local buf_opts = opts
  buf_opts['buffer'] = bufnr
  map('n', 'gD', function() vim.lsp.buf.declaration() end, buf_opts)
  map('n', 'gd', function() vim.lsp.buf.definition() end, buf_opts)
  map('n', 'K', function() vim.lsp.buf.hover() end, buf_opts)
  map('n', 'gi', function() vim.lsp.buf.implementation() end, buf_opts)
  map('n', 'gh', function() vim.lsp.buf.signature_help() end, buf_opts)
  map('n', '<space>wa', function() vim.lsp.buf.add_workspace_folder() end, buf_opts)
  map('n', '<space>wr', function() vim.lsp.buf.remove_workspace_folder() end, buf_opts)
  map('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, buf_opts)
  map('n', '<space>D', function() vim.lsp.buf.type_definition() end, buf_opts)
  map('n', '<space>rn', function() vim.lsp.buf.rename() end, buf_opts)
  map('n', '<space>ca', function() vim.lsp.buf.code_action() end, buf_opts)
  map('n', 'gr', function() vim.lsp.buf.references() end, buf_opts)
  map('n', '<space>f', function() vim.lsp.buf.formatting() end, buf_opts)
end

-- completion
-- function for Tab completion
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- setup nvim-cmp.
-- local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")
local cmp = require('cmp')
if cmp then
  cmp.setup {
    snippet = {
      expand = function(args)
          vim.fn["UltiSnips#Anon"](args.body)
      end,
    },
    mapping = {
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
        end
      end, { "c", "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      end
    end, { "c", "i", "s" }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'ultisnips' },
    { name = 'buffer' },
    {
      name = 'path',
      option = { get_cwd = function() return vim.env.PWD end },
    }
  },
}

  -- Set configuration for specific cases.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'buffer' },
    })
  })
  cmp.setup.cmdline(':', {
    sources = {
      { name = 'cmdline' }
    }
  })
  cmp.setup.cmdline('?', {
    sources = {
      { name = 'buffer' },
    }
  })
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' },
    }
  })
end

-- Setup lspconfig.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
local lspconfig = require('lspconfig')
local servers = { 'clangd', 'pylsp', 'bashls', 'texlab', 'vimls', 'sumneko_lua' }
local settings = {
  sumneko_lua = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
  pylsp = {
    pylsp = {
      plugins = {
        mccabe = {
          enabled = false,
        },
      },
    },
  },
}
for _, lsp in ipairs(servers) do
    if settings[lsp] == nil then
      settings[lsp] = {}
    end
    lspconfig[lsp].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = settings[lsp],
    }
end

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

-- harpoon
require("harpoon").setup({
  menu = {
    width = math.floor(vim.api.nvim_win_get_width(0) / 3),
  },
  excluded_filetypes = { "harpoon", "help", "floaterm" },
})

vim.api.nvim_create_autocmd({ "BufRead" }, {
  command = "silent! lua require('harpoon.mark').add_file()",
})
map('n', "<A-Tab>", function() require('harpoon.ui').nav_next() end, opts)
map('n', "<S-Tab>", function() require('harpoon.ui').nav_prev() end, opts)
map('n', "<A-h>", function() require('harpoon.ui').toggle_quick_menu() end, opts)
map('n', "<A-n>", function() require('harpoon.mark').add_file() end, opts)
for i = 1,9,1 do
  local si = string.format('%d', i)
  map('n', "<A-"..si..">", function() require('harpoon.ui').nav_file("..si..") end, opts)
end

-- floaterm
-- bg jobs
vim.g.floaterm_opener = 'edit'
map('n', "<A-c>", "<cmd>w<CR><cmd>FloatermSend compile %<CR>", opts)

-- commands
map('n', "<A-e>", "<cmd>FloatermNew ranger --cmd='set preview_images=false'<CR>", opts)
map('n', "<A-f>", "<cmd>FloatermNew fzf -m<CR>", opts)
map('n', "<A-g>", "<cmd>FloatermNew lazygit<CR>", opts)

-- interactive
map({'n', 't'}, "<A-t>", "<cmd>FloatermToggle<CR>", opts)
-- map('t', "<A-t>", "<C-\\><C-n><cmd>FloatermToggle<CR>", opts)
map('t', "<A-space>", "<C-\\><C-n>", opts)
map('t', "<A-n>", "<C-\\><C-n><cmd>FloatermNew<CR>", opts)
map('t', "<A-Tab>", "<C-\\><C-n><cmd>FloatermNext<CR>", opts)
map('t', "<S-Tab>", "<C-\\><C-n><cmd>FloatermPrev<CR>", opts)

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

-- Startup
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function ()
    vim.cmd("FloatermNew --silent")
    if vim.fn.expand('%') == '' then
      -- vim.cmd("lua require('harpoon.ui').toggle_quick_menu()")
      require('harpoon.ui').toggle_quick_menu()
    end
  end
})

-- undo tree
vim.opt.undodir = undodir
vim.opt.undofile = true
map('n', "<F5>", "<cmd>UndotreeToggle<CR>", opts)
map('n', "U", "<cmd>UndotreeShow<CR><cmd>UndotreeFocus<CR>", opts)
local undodir = vim.fn.expand("$XDG_CACHE_HOME/nvim/undo")
os.execute('mkdir -p '..undodir)
vim.g.undotree_WindowLayout = 3
