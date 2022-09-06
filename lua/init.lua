local keymap = vim.api.nvim_set_keymap
local keymap_buf = vim.api.nvim_buf_set_keymap

-- Lsp mappings
local opts = { noremap=true, silent=true }
keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  keymap_buf(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  keymap_buf(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  keymap_buf(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  keymap_buf(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  keymap_buf(bufnr, 'n', 'gh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  keymap_buf(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  keymap_buf(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  keymap_buf(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  keymap_buf(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  keymap_buf(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  keymap_buf(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  keymap_buf(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  keymap_buf(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
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
    { name = 'path' },
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
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  command = "norm zx",
})

-- harpoon
Startup = function ()
  vim.cmd("FloatermNew --silent")
  if vim.fn.expand('%') == '' then
    vim.cmd("lua require('harpoon.ui').toggle_quick_menu()")
  end
end
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  command = "lua Startup()",
})
vim.api.nvim_create_autocmd({ "BufRead" }, {
  command = "silent! lua require('harpoon.mark').add_file()",
})
keymap('n', "<A-Tab>", "<cmd>lua require('harpoon.ui').nav_next()<CR>", opts)
keymap('n', "<S-Tab>", "<cmd>lua require('harpoon.ui').nav_prev()<CR>", opts)
keymap('n', "<A-h>", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>", opts)
keymap('n', "<A-n>", "<cmd>lua require('harpoon.mark').add_file()<CR>", opts)
for i = 1,9,1 do
  local si = string.format('%d', i)
  keymap('n', "<A-"..si..">", "<cmd>lua require('harpoon.ui').nav_file("..si..")<CR>", opts)
end

-- floaterm
-- bg jobs
vim.g.floaterm_opener = 'edit'
keymap('n', "<A-c>", "<cmd>w<CR><cmd>FloatermSend compile %<CR>", opts)

-- commands
keymap('n', "<A-e>", "<cmd>FloatermNew ranger --cmd='set preview_images=false'<CR>", opts)
keymap('n', "<A-f>", "<cmd>FloatermNew fzf -m<CR>", opts)
keymap('n', "<A-g>", "<cmd>FloatermNew lazygit<CR>", opts)

-- interactive
keymap('n', "<A-t>", "<cmd>FloatermToggle<CR>", opts)
keymap("t", "<A-t>", "<C-\\><C-n><cmd>FloatermToggle<CR>", opts)
keymap("t", "<A-space>", "<C-\\><C-n>", opts)
keymap('t', "<A-n>", "<C-\\><C-n><cmd>FloatermNew<CR>", opts)
keymap('t', "<A-Tab>", "<C-\\><C-n><cmd>FloatermNext<CR>", opts)
keymap('t', "<S-Tab>", "<C-\\><C-n><cmd>FloatermPrev<CR>", opts)

-- theming
vim.cmd("colorscheme custom")
vim.api.nvim_set_option('termguicolors', true)
vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
vim.g.webdevicons_enable_airline_statusline = 1
vim.g.airline_theme='custom'
RefreshColorscheme = function ()
  vim.cmd("colorscheme custom")
  vim.cmd("AirlineTheme custom")
  vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
end
vim.api.nvim_create_autocmd({ "Signal SIGUSR1" }, {
  command = "lua RefreshColorscheme()",
})
