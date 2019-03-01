set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin('~/.vimplugins')
"Plugin Verwaltung
"Plugin 'VundleVim/Vundle.vim'

"Codeschnipsel
"Plugin 'msanders/snipmate.vim'

"Zusammengehörende Klammern durch andere ersetzen (mit cs"')
"Plugin 'tpope/vim-surround'

"Erweiterung des .-Befehls
Plugin 'tpope/vim-repeat'

"Verzeichnis durchsuchen
Plugin 'scrooloose/nerdtree'

"Automatisch Klammern schließen
"Plugin 'Raimondi/delimitMate'

"HTML Workflow
"Plugin 'mattn/emmet-vim'        

"HTML Tagclose
"Plugin 'alvan/vim-closetag'
"let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.php'

"git Änderungsanzeige
Plugin 'airblade/vim-gitgutter'

"schnell Kommentare toggeln (mit gcc)
"Plugin 'tomtom/tcomment_vim'

"schönere Statusleiste
Plugin 'itchyny/lightline.vim'
set laststatus=2

"Colorscheme: Monokai Phoenix
Plugin 'reewr/vim-monokai-phoenix'

"Operatoren hervorheben
Plugin 'Valloric/vim-operator-highlight'

"extended syntaxhighlighting for c/c++
Plugin 'bfrg/vim-cpp-modern'

"better indents for python
"Plugin 'vim-scripts/indentpython.vim'

"python syntaxhighlighting
"Plugin 'python-mode/python-mode'

"python completion
Bundle 'Valloric/YouCompleteMe'

"python check syntax
"Plugin 'vim-syntastic/syntastic'

"python PEP8 checking
"Plugin 'nvie/vim-flake8'

"latex ide
Bundle 'lervag/vimtex'
call vundle#end()            " required

let g:vimtex_view_method = 'zathura'
let g:pymode_python = 'python3'
let g:ycm_autoclose_preview_window_after_insertion = 1

filetype plugin on
set omnifunc=syntaxcomplete#Complete
autocmd FileType python set omnifunc=pythoncomplete#Complete

syntax on
colorscheme monokai-phoenix

set splitbelow

set number
set cursorline
set ignorecase

set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set expandtab

set clipboard=unnamedplus
set nowrap
set encoding=utf-8
"set scrolloff=8

set backspace=indent,eol,start

noremap gs :vsplit<LF>
noremap gS :split<LF>
noremap <F2> :NERDTree<LF>
noremap g+ :tabnew<LF>
noremap <left> <C-W>h
noremap <right> <C-W>l
noremap <up> <C-W>k
noremap <down> <C-W>j
noremap <C-left> gT
noremap <C-right> gt
noremap <C-up> :bn<LF>
noremap <C-down> :bN<LF>
noremap <F3> :w<lf>
noremap <F4> :w <bar> !gcc % && ./a.out<lf>
noremap <F5> :w <bar> !python3 %<lf>
noremap <F6> :w <bar> !bash %<lf>
noremap ZW :w<lf>
noremap zp :w <bar> :!python3 %<lf>

autocmd FileType tex :set dictionary+=~/.vim/dictionary/texdict
autocmd FileType tex :set tabstop=2
autocmd FileType tex :set shiftwidth=2
autocmd FileType tex :set softtabstop=2
