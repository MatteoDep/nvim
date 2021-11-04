" _   ___     _____ __  __                    __ _
" | \ | \ \   / /_ _|  \/  |   ___ ___  _ __  / _(_) __ _ ___
" |  \| |\ \ / / | || |\/| |  / __/ _ \| '_ \| |_| |/ _` / __|
" | |\  | \ V /  | || |  | | | (_| (_) | | | |  _| | (_| \__ \
" |_| \_|  \_/  |___|_|  |_|  \___\___/|_| |_|_| |_|\__, |___/
"                                                   |___/

" PLUGINS {{{

call plug#begin('~/.config/nvim/plugged')

" color scheme
Plug 'arcticicestudio/nord-vim'

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
Plug 'tmhedberg/SimpylFold'

" align text
Plug 'godlygeek/tabular'

" lsp
Plug 'neovim/nvim-lspconfig'

" complete
Plug 'nvim-lua/completion-nvim'
Plug 'steelsojka/completion-buffers'

" snippets tool
Plug 'SirVer/ultisnips'

" html fast coding
Plug 'mattn/emmet-vim'

" fzf
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" debugging
" Plug 'mfussenegger/nvim-dap'

" float terminal
Plug 'voldikss/vim-floaterm'

" color previews
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }

" syntaxes
Plug 'baskerville/vim-sxhkdrc'
Plug 'cespare/vim-toml'

call plug#end()

" Interesting for the future: {{{
" for asynchronous file-specific compiling
" https://github.com/tpope/vim-dispatch
" for case invariant abbreviations, substitution and change the case style of your variables
" https://github.com/tpope/vim-abolish

" }}}

" }}}

" GENERAL CONFIGS {{{

" general {{{
syntax enable							" Enables syntax highlighting
filetype plugin on		        		" vim built-in plugins
set omnifunc=syntaxcomplete#Complete 	" default omni completion
set shada+=n~/.config/nvim/main.shada	" change viminfo location
set hidden 			            		" To keep multiple buffers open
set nowrap			            		" wrap long lines
set encoding=utf-8		        		" The encoding displayed
set number relativenumber	    		" See line numbers and relative numbers
set autoindent			        		" Automatically leave space at the left as the starting line
set ruler			            		" Always display cursor
set wildmenu                    		" command-line completion enhanced
set wildmode=longest,list,full			" Display all matching files when tab complete
set nohlsearch                    		" don't highlight search
set incsearch			        		" incremental search
set noerrorbells                		" disable sound error effects
set conceallevel=2
set spelllang=en_gb,it
" }}}

" theme {{{
colorscheme nord
set background=dark
set termguicolors   " enable color previews
" airline
let g:airline#extensions#tabline#enabled = 1
let g:webdevicons_enable_airline_tabline = 1
let g:webdevicons_enable_airline_statusline = 1
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

" debugging {{{
" lua require('dap_config')
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

" LSP {{{
if expand("%:h:t") != "qutebrowser"
    lua require('lsp_config')
endif
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
" }}}

" }}}

" AUTOCOMPLETE {{{

" Use completion-nvim in every buffer
autocmd BufEnter * lua require'completion'.on_attach()
" add fuzzy completion
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
" Avoid showing message extra message when using completion
set shortmess+=c
set completeopt=menuone,noinsert,noselect

" sources
let g:completion_enable_snippet = 'UltiSnips'
let g:completion_auto_change_source = 1
let g:completion_chain_complete_list = [
    \{'complete_items': ['lsp', 'snippet']},
    \{ 'complete_items': ['buffers'] },
    \{'mode': '<c-p>'},
    \{'mode': '<c-n>'},
\]

" }}}

" KEY BINDINGS {{{

let mapleader = " "

" general {{{
" Source Vim configuration file and install plugins
nnoremap <silent><leader>1 :source $MYVIMRC \| :PlugInstall<CR>
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
nnoremap <silent> <leader>c :w \| :! compile %<CR>
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

" completion {{{
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
imap <tab> <Plug>(completion_smart_tab)
" Insert mode completion of paths with fzf
inoremap <expr> <A-i> fzf#vim#complete#path('fd')
inoremap <expr> /<A-i> fzf#vim#complete#path('locate /')
" }}}

" tabular {{{
nmap <leader>a= :Tabularize /=<CR>
vmap <leader>a= :Tabularize /=<CR>
nmap <leader>a: :Tabularize /:\zs<CR>
vmap <leader>a: :Tabularize /:\zs<CR>
nmap <leader>a, :Tabularize /,\zs<CR>
vmap <leader>a, :Tabularize /,\zs<CR>
" }}}

" debugging {{{
nnoremap <silent> <leader>dc :lua require'dap'.continue()<CR>
nnoremap <silent> <leader>dj :lua require'dap'.step_over()<CR>
nnoremap <silent> <leader>dl :lua require'dap'.step_into()<CR>
nnoremap <silent> <leader>dh :lua require'dap'.step_out()<CR>
nnoremap <silent> <leader>dt :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <leader>ds :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <leader>dsl :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
nnoremap <silent> <leader>drl :lua require'dap'.repl.run_last()<CR>
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
