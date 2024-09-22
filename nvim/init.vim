" Plugins
call plug#begin()
  Plug 'preservim/nerdtree'
  Plug 'folke/tokyonight.nvim'
  Plug 'xiyaowong/transparent.nvim'
  Plug 'itchyny/lightline.vim'
  Plug 'ziglang/zig.vim'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" Settings
let mapleader = " "
set nocompatible 
set showmatch    
set ignorecase   
set mouse=v      
set hlsearch  
set incsearch      
set tabstop=4       
set softtabstop=4          
set expandtab         
set shiftwidth=4 
set autoindent              
set number relativenumber                
set wildmode=longest,list 
filetype plugin indent on  
syntax on              
set mouse=a       
set clipboard=unnamedplus 
let g:clipboard = {
    \   'copy': {
    \       '+': ['wl-copy'],
    \       '*': ['wl-copy'],
    \   },
    \   'paste': {
    \       '+': ['wl-paste'],
    \       '*': ['wl-paste'],
    \   },
    \ }
filetype plugin on
set cursorline        
set ttyfast   
set noswapfile
colorscheme tokyonight-night
let g:lightline = {'colorscheme': 'tokyonight'}
" Disable automatic formating for zig
let g:zig_fmt_autosave = 0

" Keybinds
nnoremap <leader>t :NERDTreeToggle<CR>
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <leader>e :TransparentToggle<CR>
" Disabling arrow keys to improve muscle memory
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>
" So I can move around in insert
inoremap <C-k> <C-o>gk
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-j> <C-o>gj
" So I can actually delete
nnoremap <leader>d "_d
xnoremap <leader>d "_d
xnoremap <leader>p "_dP
