"  _   ___       _____ __  __                       __ _
" | \ | \ \   / /_ _|  \/  |   ___ ___  _ __  / _(_) __ _ ___
" |  \| |\ \ / / | || |\/| |  / __/ _ \| '_ \| |_| |/ _` / __|
" | |\  | \ V /  | || |  | | | (_| (_) | | | |  _| | (_| \__ \
" |_| \_|  \_/  |___|_|  |_|  \___\___/|_| |_|_| |_|\__, |___/
"                                                    |___/

" PLUGINS {{{

call plug#begin('~/.config/nvim/plugged')

" status line
Plug 'vim-airline/vim-airline'
" icons
Plug 'ryanoasis/vim-devicons'
" handle what surrounds a text object
Plug 'tpope/vim-surround'
" handle comments
Plug 'tpope/vim-commentary'
" extend repeat (.) abilities
Plug 'tpope/vim-repeat'
" git in vim!
Plug 'tpope/vim-fugitive'
" folds
Plug 'vitaly/folding-nvim'
" align text
Plug 'godlygeek/tabular'
" lsp
Plug 'neovim/nvim-lspconfig'
" complete
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'
" snippets tool
Plug 'SirVer/ultisnips'
" html fast coding
Plug 'mattn/emmet-vim'
" fzf
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
" float terminal
Plug 'voldikss/vim-floaterm'
" color previews
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }

call plug#end()

" }}}

" LUA SETTINGS {{{
lua require('init')
" }}}

" GENERAL CONFIGS {{{

" general {{{
syntax enable                         " Enables syntax highlighting
filetype plugin on                    " vim built-in plugins
set completeopt=menu,menuone,noselect " completion style
set shada+=n~/.config/nvim/main.shada " change viminfo location
set hidden                            " To keep multiple buffers open
set nowrap                            " wrap long lines
set encoding=utf-8                    " The encoding displayed
set number relativenumber             " See line numbers and relative numbers
set autoindent                        " Automatically leave space at the left as the starting line
set ruler                             " Always display cursor
set wildmenu                          " command-line completion enhanced
set wildmode=longest,list,full        " Display all matching files when tab complete
set nohlsearch                        " don't highlight search
set incsearch                         " incremental search
set noerrorbells                      " disable sound error effects
set conceallevel=2
set spelllang=en_gb,it
set nrformats=bin,hex,alpha           " to use ctrl-a and ctrl-x
" }}}

" theme {{{
colorscheme custom
set termguicolors
" airline
let g:airline#extensions#tabline#enabled = 1
let g:webdevicons_enable_airline_tabline = 1
let g:webdevicons_enable_airline_statusline = 1
let g:airline_theme='custom'
" hexokinase
let g:Hexokinase_highlighters = ['backgroundfull']
" }}}

" tabs {{{
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
" }}}

" python support {{{
let g:loaded_python_provider = 0
let g:python3_host_prog = '~/.config/nvim/nvim-pyenv/bin/python'
" }}}

" folding {{{
set foldmethod=syntax
autocmd BufEnter,BufRead *rc set foldmethod=marker
autocmd Filetype vim set foldmethod=marker
" }}}

" floaterm {{{
let g:floaterm_title  = "terminal"
let g:floaterm_wintype  = "split"
let g:floaterm_height = 0.8
let g:floaterm_width  = 0.8
" }}}

" fzf {{{
let g:fzf_layout = { 'down': '50%' }
" }}}

" general autocmds {{{
augroup VimStartup
    au!
    au VimEnter * if expand("%") == "" | Explore | endif
augroup END
" remove trailing spaces on save
augroup Format
    au!
    au BufWrite * :%s/\s\+$//e
augroup END
augroup Pass
    au!
    au BufRead,BufEnter */pass.*.txt set noswapfile
augroup END
augroup Sxhkd
    au!
    au BufWritePost */sxhkdrc !pkill -USR1 -x sxhkd
augroup END
augroup Rofi
    au!
    au BufNewFile,BufRead /*.rasi setf css
augroup END
augroup Nolsp
    au!
    au BufRead,BufNewFile,BufEnter *qutebrowser/config.py LspStop
augroup END
" }}}

" }}}

" KEY BINDINGS {{{

" definitions
let mapleader = " "
function RunInFloaterm(text)
    FloatermToggle
    execute "!xdotool type '".a:text."'\<CR>"
endfunction

" general {{{
" Source Vim configuration file and install plugins
nnoremap <leader>1 :w \| :source ~/.config/nvim/init.vim<CR>
" access system clipboard
vnoremap <leader>y "+y
nnoremap <leader>yy "+yy
nnoremap <leader>yiw "+yiw
vnoremap <leader>p "+p
nnoremap <leader>p "+p
nnoremap <leader>P "+P
" spell check
nnoremap <F6> :setlocal spell!<CR>
" compile
nnoremap <silent> <leader>c :w \| call RunInFloaterm('compile '.expand('%'))<CR>
"folding
nnoremap <silent> <CR> za
nnoremap <silent> <Backspace> zc
" hexokinase
nnoremap <F4> :HexokinaseToggle<CR>

" }}}

" easier exploration/substitution {{{
" fzf
nnoremap <A-e> :Explore<CR>
nnoremap <A-f> :Files<CR>
nnoremap <A-g> :GFiles<CR>
nnoremap <A-l> :Lines<CR>
nnoremap <A-b> :Buffers<CR>
vnoremap gR y:Rg <C-r>=escape(@",'/\')<CR><CR>
nnoremap gR yiw:Rg <C-r>=escape(@",'/\')<CR><CR>
" search text in buffer
vnoremap <leader>l y:BLines <C-R>=escape(@",'/\')<CR><CR>
nnoremap <leader>l yiw:BLines <C-R>=escape(@",'/\')<CR><CR>
" substitute text in buffer
vnoremap <leader>s y:%s/\V<C-R>=escape(@",'/\')<CR>//gc<Left><Left><Left>
nnoremap <leader>s yiw:%s/\<<C-R>"\>//gc<Left><Left><Left>
" }}}

" easier navigation {{{
" navigate through buffers
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprev<CR>
nnoremap ZX :bdel<CR>

" navigate through splits
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" quickfix movements
nnoremap <C-n> :cnext<CR>
nnoremap <C-p> :cprev<CR>
nnoremap <C-q> :cclose<CR>
" }}}

" floaterm {{{
let g:floaterm_keymap_new    = '<F9>'
let g:floaterm_keymap_prev   = '<F10>'
let g:floaterm_keymap_next   = '<F11>'
let g:floaterm_keymap_toggle = '<F12>'
tnoremap <A-Space> <C-\><C-n>
" }}}

" lsp {{{
nnoremap <F7> :LspStart<CR>
nnoremap <F8> :LspStop<CR>
nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gh <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> <leader>rn <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> [d <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> ]d <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap <silent> <space>f <cmd>lua vim.lsp.buf.formatting()<CR>
vnoremap <silent> <space>f <cmd>lua vim.lsp.buf.range_formatting()<CR>
" }}}

" tabular {{{
nmap <leader>a= :Tabularize /=<CR>
vmap <leader>a= :Tabularize /=<CR>
nmap <leader>a: :Tabularize /:\zs<CR>
vmap <leader>a: :Tabularize /:\zs<CR>
nmap <leader>a, :Tabularize /,\zs<CR>
vmap <leader>a, :Tabularize /,\zs<CR>
nmap <leader>aa :Tabularize /
vmap <leader>aa :Tabularize /
" }}}

" git {{{
nnoremap <leader>gg :G<Space>
nnoremap <leader>gs :G<CR>4j
nnoremap <leader>gp :G push<CR>
nnoremap <leader>gh :diffget //2<CR>
nnoremap <leader>gl :diffget //3<CR>
" }}}

" }}}

" SNIPPETS {{{

" emmet
let g:user_emmet_leader_key=','
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

" ultisnips
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"

" groff special characters shortcuts
augroup Groff
    au!
    autocmd Filetype groff inoremap á \*[']a
    autocmd Filetype groff inoremap Á \*[']A
    autocmd Filetype groff inoremap é \*[']e
    autocmd Filetype groff inoremap É \*[']E
    autocmd Filetype groff inoremap í \*[']i
    autocmd Filetype groff inoremap Í \*[']I
    autocmd Filetype groff inoremap ó \*[']o
    autocmd Filetype groff inoremap Ó \*[']O
    autocmd Filetype groff inoremap ú \*[']u
    autocmd Filetype groff inoremap Ú \*[']U
    autocmd Filetype groff inoremap à \*[`]a
    autocmd Filetype groff inoremap À \*[`]A
    autocmd Filetype groff inoremap è \*[`]e
    autocmd Filetype groff inoremap È \*[`]E
    autocmd Filetype groff inoremap ì \*[`]i
    autocmd Filetype groff inoremap Ì \*[`]I
    autocmd Filetype groff inoremap ò \*[`]o
    autocmd Filetype groff inoremap Ò \*[`]O
    autocmd Filetype groff inoremap ù \*[`]u
    autocmd Filetype groff inoremap Ù \*[`]U
augroup END

" }}}
