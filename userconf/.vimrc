"install vim-plug if not existing and install all plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !(mkdir -p ~/.vim/autoload/ &&
    \ wget -O ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim) ||
    \ curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"define plugins using vim-plug
call plug#begin('~/.vim/plugged')
"highlight trailing whitespace
Plug 'bronson/vim-trailing-whitespace'
"change root to git project
Plug 'airblade/vim-rooter'
"fast html writing
Plug 'mattn/emmet-vim', { 'for': 'html' }
"substitute brackets with others (cs"')
Plug 'tpope/vim-surround'
"extension of .-command
Plug 'tpope/vim-repeat'
"git wrapper
Plug 'tpope/vim-fugitive'
"git diff on left sidebar
Plug 'airblade/vim-gitgutter'
"beautiful statusbar
Plug 'itchyny/lightline.vim'
"snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
"colorschemes
Plug 'flazz/vim-colorschemes'
Plug 'sheerun/vim-polyglot'
"highlight operators
Plug 'Valloric/vim-operator-highlight'
"interactive console (send lines of file)
Plug 'jalvesaq/vimcmdline'
"completion
Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }
"explore directory
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
"view concept definitions
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
"buffer explorer
Plug 'jlanzarotta/bufexplorer', { 'on': 'ToggleBufExplorer' }
"super searching
Plug 'kien/ctrlp.vim', { 'on': 'CtrlP' }
"python ide
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
"R ide
Plug 'jalvesaq/Nvim-R', { 'for': 'r' }
"latex ide
Plug 'lervag/vimtex', { 'for': 'latex' }
"semantic highlighting of python code
Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' }
"Plug 'jaxbot/semantic-highlight.vim'
"compile/run
Plug 'vim-scripts/SingleCompile', { 'on': 'SCCompile' }
"csv viewer
Plug 'chrisbra/csv.vim'
"multiple cursors
Plug 'terryma/vim-multiple-cursors'
"wrap function arguments
Plug 'foosoft/vim-argwrap'
"exchange words
Plug 'tommcdo/vim-exchange'
"manipulate function arguments
Plug 'inkarkat/argtextobj.vim'
"swap objects like function arguments
Plug 'AndrewRadev/sideways.vim'
"textobj extension
Plug 'wellle/targets.vim'
"search for text in files
Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }
"textobj for indents
Plug 'michaeljsmith/vim-indent-object'
" % match more
Plug 'vim-scripts/matchit.zip'
call plug#end()

"solarized colorscheme
let g:solarized_termcolors = 256

"lightline
set laststatus=2

"CtrlP
noremap <C-p> :CtrlP<CR>

"ultisnips
let g:ulti_expand_res = 0
function! Ulti_ExpandOrJump_and_getRes()
    call UltiSnips#ExpandSnippet()
    return g:ulti_expand_res
endfunction

"inoremap <CR> <C-R>=(Ulti_ExpandOrJump_and_getRes() > 0)?"":"\n"<CR>
"let g:UltiSnipsExpandSnippet = '<NUL>'
let g:UltiSnipsExpandTrigger = '<c-j>'
let g:UltiSnipsJumpForwardTrigger = '<c-o>'
let g:UltiSnipsJumpBackwardTrigger = '<c-i>'

"vimtex
let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'zathura'
let g:vimtex_quickfix_mode = 0
set conceallevel=1
let g:tex_conceal = 'abdmg'

if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif
au VimEnter * let g:ycm_semantic_triggers.tex=g:vimtex#re#youcompleteme

autocmd FileType tex :set dictionary+=~/.vim/dictionary/texdict
autocmd FileType tex :set tabstop=2
autocmd FileType tex :set shiftwidth=2
autocmd FileType tex :set softtabstop=2

"polyglot
let g:polyglot_disabled = ['latex']

"vimcmdline
let cmdline_vsplit = 1
let cmdline_map_send = '<space>'
let cmdline_map_send_paragraph = '<C-space>'

"semshi
let g:semshi#mark_selected_nodes = 0
let g:semshi#simplify_markup = v:false
let g:semshi#error_sign = v:false

"pymode
let g:pymode_python = 'python3'
let g:pymode_rope = 0
let g:pymode_rope_completion = 0
let g:pymode_lint = 0
let g:pymode_syntax = 0

"SingleCompile'
let g:SingleCompile_usetee = 0
let g:SingleCompile_usequickfix = 0
noremap <F9> <Esc>:w<CR>:SCCompile<CR>

"YCM
let g:ycm_autoclose_preview_window_after_insertion = 1
filetype plugin on
set omnifunc=syntaxcomplete#Complete
autocmd FileType python set omnifunc=pythoncomplete#Complete

"Nvim-R
let R_in_buffer = 1
let R_term = 'xterm'
let R_esc_term = 0
let R_close_term = 1
let R_min_editor_width = -80

"argwrap
nnoremap Y :ArgWrap<CR>

"sideways
nnoremap R :SidewaysLeft<CR>
nnoremap U :SidewaysRight<CR>

"grepper
nnoremap <C-m> :Grepper<CR>


autocmd VimEnter * if exists(':RSend') | noremap <space> :call SendParagraphToR('silent', 'down')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap <C-space> :call SendLineToR('down')<CR>| endif
"autocmd VimEnter * if exists(':RSend') | noremap <C-s> :call SendFileToR('silent')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap ZR :call StartR('R')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap ZE :call RQuit('nosave')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap ZH :call RAction('help')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap ZV :call RAction('viewdf')<CR>| endif

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
set splitright

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

set relativenumber

noremap <C-o> :tabnext<CR>
noremap <C-i> :tabprevious<CR>
noremap Q :qa<CR>
noremap <C-q> :bd<CR>
noremap gs :vsplit<CR>
noremap gS :split<CR>
noremap <F2> :NERDTreeToggle<CR>
noremap <F3> :TagbarToggle<CR>
noremap <F4> :ToggleBufExplorer<CR>
noremap gt :tabnew<CR>
noremap <left> <C-W>H
noremap <right> <C-W>L
noremap <up> <C-W>K
noremap <down> <C-W>J
noremap <C-h> <C-W>h
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-l> <C-W>l
noremap <F5> :setlocal spell! spelllang=en_us<CR>
noremap <F6> :setlocal spell! spelllang=de_de<CR>
nnoremap ö :noh<CR>
noremap ZW :w<CR>

tnoremap <C-h> <C-\><C-n><C-W>h
tnoremap <C-j> <C-\><C-n><C-W>j
tnoremap <C-k> <C-\><C-n><C-W>k
tnoremap <C-l> <C-\><C-n><C-W>l
