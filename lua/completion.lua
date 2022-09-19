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
