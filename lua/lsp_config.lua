-- LSP ------------------------------------------------------------------------
local nvim_lsp = require('lspconfig')

nvim_lsp.pyls.setup{
    settings = {
        pyls = {
            plugins = {
                pydocstyle = { enabled = true; }
            };
            configurationSources = { "flake8" };
        };
    };
}
require'lspconfig'.ccls.setup{}
require'lspconfig'.bashls.setup{}
