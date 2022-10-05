local map = vim.keymap.set
local opts = { noremap=true, silent=true }

-- Lsp mappings
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

-- Setup lspconfig.
local lspconfig = require('lspconfig')
local servers = { 'clangd', 'pylsp', 'bashls', 'texlab', 'vimls', 'sumneko_lua' }
local settings = {
  texlab = {
    texlab = {
      auxDirectory = '.auxdir',
      diagnostics = {
        ignoredPatterns = { 'Underfull' },
      },
    },
  },
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
      on_attach = on_attach,
      settings = settings[lsp],
    }
end
