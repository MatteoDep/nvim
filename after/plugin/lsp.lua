--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr, desc = '[R]e[n]ame' })
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = '[C]ode [A]ction' })

  vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, { buffer = bufnr, desc = '[G]oto [D]efinition' })
  vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { buffer = bufnr, desc = '[G]oto [R]eferences' })
  vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, { buffer = bufnr, desc = '[G]oto [I]mplementation' })
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, { buffer = bufnr, desc = 'Type [D]efinition' })
  vim.keymap.set('n', '<leader>sD', require('telescope.builtin').lsp_document_symbols,
    { buffer = bufnr, desc = '[S]earch [D]ocument symbols' })
  vim.keymap.set('n', '<leader>sW', require('telescope.builtin').lsp_dynamic_workspace_symbols,
    { buffer = bufnr, desc = '[S]earch [W]orkspace symbols' })

  -- See `:help K` for why this keymap
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = 'Hover Documentation' })
  vim.keymap.set('n', 'gh', vim.lsp.buf.signature_help, { buffer = bufnr, desc = 'Signature Documentation' })
  vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, { buffer = bufnr, desc = 'Signature Documentation' })

  -- Lesser used LSP functionality
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = bufnr, desc = '[G]oto [D]eclaration' })
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, { buffer = bufnr, desc = '[W]orkspace [A]dd Folder' })
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder,
    { buffer = bufnr, desc = '[W]orkspace [R]emove Folder' })
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, { buffer = bufnr, desc = '[W]orkspace [L]ist Folders' })

  vim.keymap.set({ 'n', 'v' }, '<leader>f', vim.lsp.buf.format, { silent = true, desc = 'Format current buffer with LSP' })
end

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local function complete_server_setup(t)
  if t.capabilities == nil then
    t.capabilities = capabilities
  end
  if t.on_attach == nil then
    t.on_attach = on_attach
  end
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  pyright = {
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "off",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          reportUnusedVariables = false,
        },
      },
    },
  },
  csharp_ls = {},
  tsserver = {},
  bashls = {},
  jsonls = {},
  gopls = {},
  ruff_lsp = {},
  cssls = {},
  html = {
    filetypes = { "html", "templ" },
  },
  tailwindcss = {
    filetypes = { "templ", "astro", "javascript", "typescript", "react" },
    init_options = { userLanguages = { templ = "html" } },
  },
  htmx = {
    filetypes = { "html", "templ" },
  },
  templ = {},
  yamlls = {},
}

-- Setup neovim lua configuration
require('neodev').setup()

-- Setup mason so it can manage external tooling
require('mason').setup()

local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    complete_server_setup(servers[server_name])
    require('lspconfig')[server_name].setup(servers[server_name])
  end,
}

-- Turn on lsp status information
require('fidget').setup({})

-- none (null) ls
local null_ls = require("null-ls")
local null_ls_sources = require("null-ls.sources")

null_ls.disable()
null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.mypy.with({
      command = "mypy",
    }),
  },
})
vim.keymap.set('n', '<leader>DD', function()
    for _, source in ipairs(null_ls_sources.get_all()) do
      null_ls.toggle(source.name)
    end
  end, { desc = '[D]isable null-ls source' })
