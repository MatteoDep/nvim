vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = event.buf, desc = '[R]e[n]ame' })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = event.buf, desc = '[C]ode [A]ction' })

    vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions,
      { buffer = event.buf, desc = '[G]oto [D]efinition' })
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references,
      { buffer = event.buf, desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, { buffer = event.buf, desc = '[G]oto [I]mplementation' })
    vim.keymap.set('n', '<leader>td', vim.lsp.buf.type_definition, { buffer = event.buf, desc = 'Type [D]efinition' })
    vim.keymap.set('n', '<leader>sD', require('telescope.builtin').lsp_document_symbols,
      { buffer = event.buf, desc = '[S]earch [D]ocument symbols' })
    vim.keymap.set('n', '<leader>sW', require('telescope.builtin').lsp_dynamic_workspace_symbols,
      { buffer = event.buf, desc = '[S]earch [W]orkspace symbols' })

    -- See `:help K` for why this keymap
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = event.buf, desc = 'Hover Documentation' })
    vim.keymap.set('n', 'gh', vim.lsp.buf.signature_help, { buffer = event.buf, desc = 'Signature Documentation' })
    vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, { buffer = event.buf, desc = 'Signature Documentation' })

    -- Lesser used LSP functionality
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = event.buf, desc = '[G]oto [D]eclaration' })
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder,
      { buffer = event.buf, desc = '[W]orkspace [A]dd Folder' })
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder,
      { buffer = event.buf, desc = '[W]orkspace [R]emove Folder' })
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, { buffer = event.buf, desc = '[W]orkspace [L]ist Folders' })

    vim.keymap.set({ 'n', 'v' }, '<leader>f', vim.lsp.buf.format,
      { silent = true, desc = 'Format current buffer with LSP' })

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
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
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      vim.keymap.set('n', '<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, { desc = '[T]oggle Inlay [H]ints' })
    end
  end,
})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

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
  ts_ls = {},
  bashls = {},
  jsonls = {},
  gopls = {},
  ruff = {},
  rust_analyzer = {},
  cssls = {},
  html = {
    filetypes = { "html" },
  },
  tailwindcss = {
    filetypes = { "templ", "astro", "javascript", "typescript", "react" },
    -- init_options = { userLanguages = { templ = "html" } },
  },
  templ = {},
  yamlls = {},
  helm_ls = {},
}
if vim.fn.has("win32") == 0 then
  servers["htmx"] = {
    filetypes = { "html", "templ" },
  }
end

-- Setup neovim lua configuration
require('neodev').setup()

-- Setup mason so it can manage external tooling
require('mason').setup()

require('mason-tool-installer').setup { ensure_installed = vim.tbl_keys(servers) }

require('mason-lspconfig').setup {
  handlers = {
    function(server_name)
      local server = servers[server_name] or {}
      -- This handles overriding only values explicitly passed
      -- by the server configuration above. Useful when disabling
      -- certain features of an LSP (for example, turning off formatting for ts_ls)
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      require('lspconfig')[server_name].setup(server)
    end,
  },
  ensure_installed = {},
  automatic_installation = true,
}

-- Turn on lsp status information
require('fidget').setup({})

-- none (null) ls
local null_ls = require("null-ls")
local null_ls_sources = require("null-ls.sources")

null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.mypy,
  },
})
vim.keymap.set('n', '<leader>0', function()
  for _, source in ipairs(null_ls_sources.get_all()) do
    null_ls.toggle(source.name)
  end
end, { desc = '[T]oggle null-ls source' })
