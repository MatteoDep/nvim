-- Setup nvim-cmp.
local cmp = require 'cmp'
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
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'ultisnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
}
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

-- folding
function on_attach_callback(client, bufnr)
  require('folding').on_attach()
end

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lspconfig = require('lspconfig')
local servers = { 'clangd', 'pylsp', 'bashls', 'texlab', 'vimls' }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
      capabilities = capabilities,
      on_attach = on_attach_callback,
    }
end
