"install vim-plug if not existing and install all plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !(mkdir -p ~/.vim/autoload/ &&
    \ wget -O ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim) ||
    \ curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"define plugins using vim-plug
call plug#begin('~/.vim/plugged')
"autoclose brackets
Plug 'raimondi/delimitmate'
"toggle comment
Plug 'scrooloose/nerdcommenter'
"buffer explorer
Plug 'fholgado/minibufexpl.vim'
"async lint
Plug 'w0rp/ale'
"highlight colorcodes
Plug 'ap/vim-css-color'
"highlight trailing whitespace
Plug 'bronson/vim-trailing-whitespace'
"change root to git project
Plug 'airblade/vim-rooter'
"fast html writing
Plug 'mattn/emmet-vim'
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
Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }
"explore directory
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
"view concept definitions
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
"super searching
Plug 'ctrlpvim/ctrlp.vim', { 'on': 'CtrlP' }
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
"textobj for indents
Plug 'michaeljsmith/vim-indent-object'
" % match more
Plug 'vim-scripts/matchit.zip'
call plug#end()

"NERDCommenter
let g:NERDDefaultAlign='start'

"minibufexpl
let g:miniBufExplVSplit = 20
let g:miniBufExplBRSplit = 0
let g:miniBufExplShowBufNumbers = 0
let g:miniBufExplorerAutoStart = 0

"ale
let g:ale_python_auto_pipenv = 0
let g:ale_linters = {'python': ['pylint', 'flake8', 'bandit']}
"let g:ale_linters_ignore = {'python': ['mypy']}
let g:ale_lint_on_enter = 1
let g:ale_lint_on_text_changed = 0
let g:ale_python_pylint_options = "-d C0111,W0703,C0103"

"solarized colorscheme
let g:solarized_termcolors = 256

"lightline
set laststatus=2

"CtrlP
noremap <C-p> :CtrlP<CR>

"ultisnips
let g:UltiSnipsExpandTrigger = '<NUL>'

"vimtex
let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'zathura'
let g:vimtex_quickfix_mode = 2
"let g:vimtex_quickfix_autoclose_after_keystrokes = 1
"let g:vimtex_quickfix_ignore_all_warnings = 1
"let g:vimtex_quickfix_open_on_warning = 0
let g:vimtex_quickfix_latexlog = {
      \ 'overfull' : 0,
      \ 'underfull' : 0,
      \ 'packages' : {
      \   'default' : 0,
      \ },
      \}
set conceallevel=1
let g:tex_conceal = 'abdmg'

if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif
au VimEnter * let g:ycm_semantic_triggers.tex=g:vimtex#re#youcompleteme

autocmd FileType tex :set tabstop=2
autocmd FileType tex :set shiftwidth=2
autocmd FileType tex :set softtabstop=2
autocmd FileType tex :set indentexpr=""

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
"let g:pymode_python = 'python3'
"let g:pymode_rope = 1
"let g:pymode_rope_completion = 1
"let g:pymode_rope_lookup_project = 1
"let g:pymode_lint = 1
"let g:pymode_syntax = 0
"let g:pymode_run_bind = '<NUL>'

"SingleCompile'
let g:SingleCompile_usetee = 0
let g:SingleCompile_usequickfix = 0
noremap <F9> <Esc>:w<CR>:SCCompile<CR>

"YCM
"let g:ycm_autoclose_preview_window_after_insertion = 1
"set omnifunc=syntaxcomplete#Complete
"autocmd FileType python set omnifunc=pythoncomplete#Complete

"coc.nvim
inoremap <silent><expr> <c-space> coc#refresh()

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<c-n>" :
    \ <sid>check_back_space() ? "\<tab>" :
    \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

nmap <leader>rn <Plug>(coc-rename)
let g:coc_snippet_next = '<C-o>'
let g:coc_snippet_prev = '<C-i>'
imap <C-j> <Plug>(coc-snippets-expand)
let g:coc_global_extensions = ['coc-css', 'coc-emmet', 'coc-html', 'coc-json', 'coc-python', 'coc-snippets', 'coc-ultisnips', 'coc-vimtex', 'coc-yaml']

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

"tagbar
let g:tagbar_autofocus = 1


autocmd VimEnter * if exists(':RSend') | noremap <space> :call SendParagraphToR('silent', 'down')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap <C-space> :call SendLineToR('down')<CR>| endif
"autocmd VimEnter * if exists(':RSend') | noremap <C-s> :call SendFileToR('silent')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap ZR :call StartR('R')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap ZE :call RQuit('nosave')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap ZH :call RAction('help')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap ZV :call RAction('viewdf')<CR>| endif


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
set smartindent
set expandtab

if has('unnamedplus')
  set clipboard=unnamed,unnamedplus
endif
set nowrap
set encoding=utf-8
set scrolloff=8

set backspace=indent,eol,start

set relativenumber

set nobackup
set nowritebackup
set cmdheight=2

noremap <C-o> :tabnext<CR>
noremap <C-i> :tabprevious<CR>
noremap Q :qa<CR>
noremap <C-q> :bd<CR>
noremap gs :vsplit<CR>
noremap gS :split<CR>
noremap <F1> :NERDTreeToggle<CR>
noremap <F2> :MBEToggleAll<CR> :MBEFocus<CR> <C-W>=
noremap <F3> :TagbarToggle<CR>
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
noremap + :m+<CR>
noremap - :m-2<CR>
nmap <CR> <Plug>NERDCommenterToggle
vmap <CR> <Plug>NERDCommenterToggle gv

vmap < <gv
vmap > >gv

tnoremap <C-h> <C-\><C-n><C-W>h
tnoremap <C-j> <C-\><C-n><C-W>j
tnoremap <C-k> <C-\><C-n><C-W>k
tnoremap <C-l> <C-\><C-n><C-W>l
