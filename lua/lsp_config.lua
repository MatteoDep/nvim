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
nvim_lsp.ccls.setup{}
nvim_lsp.bashls.setup{}
nvim_lsp.texlab.setup{}
