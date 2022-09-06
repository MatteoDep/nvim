#!/bin/sh

pip install "python-lsp-server[pycodestyle,pyflakes,autopep8]"
p -S clang
p -S bash-language-server
p -S texlab
paru -S vim-language-server
paru -S lua-language-server
paru -S ltex-ls-bin
