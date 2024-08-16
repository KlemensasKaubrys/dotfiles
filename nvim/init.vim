" Plugins
call plug#begin()
  Plug 'preservim/nerdtree'
  Plug 'folke/tokyonight.nvim'
  Plug 'xiyaowong/transparent.nvim'
  Plug 'itchyny/lightline.vim'
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
    \       '+': ['wl-copy', '--trim-newline'],
    \       '*': ['wl-copy', '--trim-newline'],
    \   },
    \   'paste': {
    \       '+': ['wl-paste', '--no-newline'],
    \       '*': ['wl-paste', '--no-newline'],
    \   },
    \ }
filetype plugin on
set cursorline        
set ttyfast   
set noswapfile
colorscheme tokyonight-night
let g:lightline = {'colorscheme': 'tokyonight'}

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
"So I can move around in insert
inoremap <C-k> <C-o>gk
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-j> <C-o>gj

