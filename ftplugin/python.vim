setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal expandtab
setlocal textwidth=120
setlocal autoindent
setlocal smarttab
setlocal formatoptions=tcrvqlj
" let g:SimpylFold_docstring_preview = 1

if executable('autopep8')
    vnoremap <silent> <space>f !autopep8 -a -a --global-config ~/.config/flake8 -<CR>
endif

if executable('docformatter')
    vnoremap <silent> <space>d !docformatter -<CR>
    nnoremap <silent> <space>d :%!docformatter -<CR>
endif
