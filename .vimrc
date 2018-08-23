set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
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

"Colorscheme: Monokai Phoenix
Plugin 'reewr/vim-monokai-phoenix'

" All of your Plugins must be added before the following line
call vundle#end()            " required
"filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

syntax on
set number
colorscheme monokai-phoenix
set cursorline
set ignorecase

set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set expandtab
set clipboard=unnamedplus

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
