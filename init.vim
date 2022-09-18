"  _   ___	   _____ __  __					   __ _
" | \ | \ \   / /_ _|  \/  |   ___ ___  _ __  / _(_) __ _ ___
" |  \| |\ \ / / | || |\/| |  / __/ _ \| '_ \| |_| |/ _` / __|
" | |\  | \ V /  | || |  | | | (_| (_) | | | |  _| | (_| \__ \
" |_| \_|  \_/  |___|_|  |_|  \___\___/|_| |_|_| |_|\__, |___/
"													|___/

" PLUGINS
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
	" Harpoon
	Plug 'nvim-lua/plenary.nvim'
	Plug 'ThePrimeagen/harpoon'
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
	" treesitter
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
	Plug 'nvim-treesitter/nvim-treesitter-context'
	Plug 'p00f/nvim-ts-rainbow'
	" align text
	Plug 'godlygeek/tabular'
	" color previews
	Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
	" floaterm
	Plug 'voldikss/vim-floaterm'
call plug#end()

" LUA SETTINGS
lua require('init')

" GENERAL CONFIGS

" general
syntax enable						 " Enables syntax highlighting
filetype plugin on					" vim built-in plugins
set completeopt=menu,menuone,noselect " completion style
set shada+=n~/.config/nvim/main.shada " change viminfo location
set hidden							" To keep multiple buffers open
set nowrap							" wrap long lines
set encoding=utf-8					" The encoding displayed
set number relativenumber			 " See line numbers and relative numbers
set autoindent						" Automatically leave space at the left as the starting line
set ruler							 " Always display cursor
set wildmenu						  " command-line completion enhanced
set wildmode=longest,list,full		" Display all matching files when tab complete
set nohlsearch						" don't highlight search
set incsearch						 " incremental search
set noerrorbells					  " disable sound error effects
set conceallevel=2
set spelllang=en_us,it
set nrformats=bin,hex,alpha		   " to use ctrl-a and ctrl-x
set formatoptions=tcrvqlj
" hexokinase
let g:Hexokinase_highlighters = ['backgroundfull']
let g:Hexokinase_ftEnabled = ['css', 'html', 'javascript']
" tabs
set tabstop=4
set shiftwidth=4
set softtabstop=4
set noexpandtab
" python support
let g:loaded_python_provider = 0
let g:python3_host_prog = '~/.config/nvim/nvim-pyenv/bin/python'
" folding
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

" general autocmds
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
	au BufNewFile,BufRead /*.rasi setfiletype css
augroup END
augroup Nolsp
	au!
	au BufRead,BufNewFile,BufEnter *qutebrowser/config.py LspStop
augroup END
augroup FiletypeDetection
	au!
	au BufRead,BufNewFile,BufEnter *.tex setfiletype tex
augroup END

" KEY BINDINGS

" definitions
let mapleader = " "

nnoremap <leader>1 :source ~/.config/nvim/init.vim<CR>
" access system clipboard
vnoremap <leader>y "+y
nnoremap <leader>yy "+yy
nnoremap <leader>yiw "+yiw
vnoremap <leader>p "+p
nnoremap <leader>p "+p
nnoremap <leader>P "+P
"folding
nnoremap <silent> <Space><Space> za
nnoremap <silent> <Space><CR> zA
" spell check
nnoremap <F6> :setlocal spell!<CR>
" hexokinase
nnoremap <F4> :HexokinaseToggle<CR>

" easier exploration/substitution
" fzf
" nnoremap <A-f> :Files<CR>
" nnoremap <A-l> :Lines<CR>
vnoremap gR y:FloatermNew rg <C-r>=escape(@",'/\')<CR><CR>
nnoremap gR yiw:FloatermNew rg <C-r>"<CR>
" search text in buffer
vnoremap <leader>l y:Lines <C-R>=escape(@",'/\')<CR><CR>
nnoremap <leader>l yiw:Lines <C-R>"<CR>
" substitute text in buffer
vnoremap <leader>s y:%s/\V<C-R>=escape(@",'/\')<CR>//gc<Left><Left><Left>
nnoremap <leader>s yiw:%s/\<<C-R>"\>//gc<Left><Left><Left>

" navigate through buffers
" nnoremap <A-Tab> :bnext<CR>
" nnoremap <S-Tab> :bprev<CR>
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

" lsp
nnoremap <F7> :LspStart<CR>
nnoremap <F8> :LspStop<CR>

" tabular
nmap <leader>a= :Tabularize /=<CR>
vmap <leader>a= :Tabularize /=<CR>
nmap <leader>a: :Tabularize /:\zs<CR>
vmap <leader>a: :Tabularize /:\zs<CR>
nmap <leader>a, :Tabularize /,\zs<CR>
vmap <leader>a, :Tabularize /,\zs<CR>
nmap <leader>aa :Tabularize /
vmap <leader>aa :Tabularize /

" ultisnips
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
