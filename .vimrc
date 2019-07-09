set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin('~/.vimplugins')
"Codeschnipsel
"Plugin 'msanders/snipmate.vim'

"Automatisch Klammern schließen
"Plugin 'Raimondi/delimitMate'

"better indents for python
"Plugin 'vim-scripts/indentpython.vim'

"Zusammengehörende Klammern durch andere ersetzen (mit cs"')
Plugin 'tpope/vim-surround'

"Erweiterung des .-Befehls
Plugin 'tpope/vim-repeat'

"Verzeichnis durchsuchen
Plugin 'scrooloose/nerdtree'

"git Änderungsanzeige
Plugin 'airblade/vim-gitgutter'

"schönere Statusleiste
Plugin 'itchyny/lightline.vim'
set laststatus=2

"Colorscheme: Monokai Phoenix
Plugin 'reewr/vim-monokai-phoenix'

"Operatoren hervorheben
Plugin 'Valloric/vim-operator-highlight'

"python ide
Plugin 'python-mode/python-mode'

"completion
Plugin 'Valloric/YouCompleteMe'

"super searching
Plugin 'kien/ctrlp.vim'

"latex ide
Plugin 'lervag/vimtex'

"semantic highlighting
Plugin 'numirias/semshi'
call vundle#end()            " required

let g:vimtex_view_method = 'zathura'
let g:pymode_python = 'python3'
let g:ycm_autoclose_preview_window_after_insertion = 1

"semshi
let g:semshi#mark_selected_nodes = 0
let g:semshi#simplify_markup = v:false
let g:semshi#error_sign = v:false

"pymode
let g:pymode_rope = 0
let g:pymode_rope_completion = 0
let g:pymode_lint = 0
let g:pymode_syntax = 0

filetype plugin on
set omnifunc=syntaxcomplete#Complete
autocmd FileType python set omnifunc=pythoncomplete#Complete

" Virtualenv support
py3 << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  exec(compile(open(activate_this, "rb").read(), activate_this, 'exec'), dict(__file__=activate_this))
EOF

colorscheme monokai-phoenix
syntax on

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
set scrolloff=8

set backspace=indent,eol,start

noremap gs :vsplit<LF>
noremap gS :split<LF>
noremap <F2> :NERDTree<LF>
noremap g+ :tabnew<LF>
noremap <left> gT
noremap <right> gt
noremap <up> :bn<LF>
noremap <down> :bN<LF>
noremap <C-left> <C-W>H
noremap <C-right> <C-W>L
noremap <C-up> <C-W>K
noremap <C-down> <C-W>J
noremap <C-h> <C-W>h
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-l> <C-W>l
noremap <F5> :setlocal spell! spelllang=en_us<CR>
noremap <F6> :setlocal spell! spelllang=de_de<CR>
noremap <F7> :noh<CR>
noremap ZW :w<LF>

autocmd FileType tex :set dictionary+=~/.vim/dictionary/texdict
autocmd FileType tex :set tabstop=2
autocmd FileType tex :set shiftwidth=2
autocmd FileType tex :set softtabstop=2
