"install vim-plug if not existing and install all plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !(mkdir -p ~/.vim/autoload/ && wget -O ~/.vim/autoload/plug.vim 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
         \ || curl -fLo '~/.vim/autoload/plug.vim' --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"define plugins using vim-plug
call plug#begin('~/.vim/plugged')
"interact with quickfix
Plug 'romainl/vim-qf'
"improve search
Plug 'haya14busa/vim-asterisk'
"debugger
"Plug 'puremourning/vimspector', { 'do': './install_gadget.py --enable-python' }
"xpath
Plug 'actionshrimp/vim-xpath'
"json pretty print
Plug 'tpope/vim-jdaddy'
"markdown preview ( requires: 'npm -g install instant-markdown-d || pip install --user smdv' )
Plug 'suan/vim-instant-markdown', { 'for': 'markdown'}
"rainbow parenthese
Plug 'luochen1990/rainbow', { 'for': ['python', 'c', 'cpp', 'lisp', 'html', 'vim', 'java'] }
"load hugefiles faster
"Plug 'mhinz/vim-hugefile'
"highlight colorcodes
Plug 'ap/vim-css-color'
"align statements
Plug 'junegunn/vim-easy-align'
"session handling
Plug 'tpope/vim-obsession'
"greplike search
Plug 'mileszs/ack.vim'
"completion terms from other tmux pane
Plug 'wellle/tmux-complete.vim'
"textobj for python
Plug 'jeetsukumaran/vim-pythonsense'
"focus commands work in tmux
Plug 'tmux-plugins/vim-tmux-focus-events'
"execute command in tmux pane
Plug 'benmills/vimux'
"toggle comment
Plug 'scrooloose/nerdcommenter', { 'on': '<Plug>NERDCommenterToggle' }
"buffer explorer
Plug 'madKuchenbaecker/minibufexpl.vim'
"async lint
Plug 'w0rp/ale'
"highlight trailing whitespace
Plug 'ntpeters/vim-better-whitespace'
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
Plug 'reewr/vim-monokai-phoenix'
" better language behavior
Plug 'sheerun/vim-polyglot'
"completion
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
"explore directory
Plug 'scrooloose/nerdtree'
"git integration with nerdtree
Plug 'Xuyuanp/nerdtree-git-plugin'
"view concept definitions
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
"super searching
Plug 'junegunn/fzf', { 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
"R ide
Plug 'jalvesaq/Nvim-R', { 'for': 'r' }
"send commands to console
Plug 'jalvesaq/vimcmdline'
"latex ide ( requires: 'pip install neovim-remote' )
Plug 'lervag/vimtex', { 'for': 'latex' }
"semantic highlighting of python code
Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins', 'for': 'python' }
"compile/run
Plug 'vim-scripts/SingleCompile', { 'on': 'SCCompile' }
"csv inspector/arranger
Plug 'chrisbra/csv.vim'
"wrap function arguments
Plug 'foosoft/vim-argwrap', { 'on': 'ArgWrap' }
"swap objects like function arguments
Plug 'AndrewRadev/sideways.vim', { 'on': ['SidewaysLeft', 'SidewaysRight'] }
"textobj extension
Plug 'wellle/targets.vim'
"textobj for indents
Plug 'michaeljsmith/vim-indent-object'
"% match more
Plug 'vim-scripts/matchit.zip'
call plug#end()

" ----------------------------------
" --- Begin Plugin Configuration ---
" ----------------------------------

"vim-asterisk
map *   <Plug>(asterisk-*)
map #   <Plug>(asterisk-#)
map g*  <Plug>(asterisk-g*)
map g#  <Plug>(asterisk-g#)
map z*  <Plug>(asterisk-z*)
map gz* <Plug>(asterisk-gz*)
map z#  <Plug>(asterisk-z#)
map gz# <Plug>(asterisk-gz#)

"vim-qf
map Ö <Plug>(qf_qf_toggle)

"vimspector
let g:vimspector_enable_mappings = 'HUMAN'

"pythonsense
let g:is_pythonsense_suppress_motion_keymaps = 1

"easy align
vmap <Enter> <Plug>(EasyAlign)

"rainbow
let g:rainbow_active = 1
let g:rainbow_conf = {
\	'ctermfgs': ['cyan', 'red', 'green', 'yellow'],
\	'parentheses': ['start=/(/ end=/)/ fold', 'start=/{/ end=/}/ fold'],
\	'separately': {
\		'*': {},
\       'html': 0,
\		'css': 0,
\       'latex': 0,
\	}
\}

"ack
cnoreabbrev Ack Ack!
nnoremap <Leader>a :Ack!<Space>
let g:ack_default_options = " -S -s -H --nocolor --nogroup --column"

"NERDTree
let NERDTreeMinimalUI = 1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | :wincmd h | endif
let g:NERDTreeIgnore = ['__pycache__']
nnoremap <silent> <F1> :NERDTreeToggle<CR>
inoremap <silent> <F1> <ESC>:NERDTreeToggle<CR>
nnoremap <silent> gt :NERDTreeFind<CR>

"NERDCommenter
let g:NERDDefaultAlign='start'
nmap gc <Plug>NERDCommenterToggle
vmap gc <Plug>NERDCommenterToggle gv

"minibufexpl
let g:miniBufExplVSplit = 20
let g:miniBufExplBRSplit = 1
let g:miniBufExplShowBufNumbers = 0
let g:miniBufExplorerAutoStart = 0
nmap <silent> <F2> :MBEToggle<CR>:MBEFocus<CR><C-W>=
imap <silent> <F2> <ESC>:MBEToggle<CR>:MBEFocus<CR><C-W>=

"ale
let g:ale_set_highlights = 0
let g:ale_python_auto_pipenv = 0
let g:ale_linters = {'python': ['pylint', 'flake8']}
let g:ale_lint_on_enter = 0
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_text_changed = 0
let g:ale_python_pylint_options = "-d C0111,W0703,C0103,E0401,R0201,R0903"
let g:ale_fixers = {
\  'javascript': ['prettier'],
\  'python': ['black', 'isort']
\}
nnoremap <F5> :ALEFix<CR>
inoremap <F5> <ESC>:ALEFix<CR>

"solarized colorscheme
let g:solarized_termcolors = 256

"lightline
set laststatus=2

"fzf
noremap <silent> <C-p> :FZF<CR>
inoremap <silent> <C-p> <ESC>:FZF<CR>

"ultisnips
let g:UltiSnipsExpandTrigger = '<NUL>'

"vimtex
let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_matchparen_enabled = 0
let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'zathura'
let g:vimtex_quickfix_mode = 2
let g:vimtex_view_skim_reading_bar = 0
let g:vimtex_quickfix_autoclose_after_keystrokes = 1
let g:vimtex_quickfix_ignore_all_warnings = 1
let g:vimtex_quickfix_open_on_warning = 0
let g:vimtex_quickfix_latexlog = {
      \ 'overfull' : 0,
      \ 'underfull' : 0,
      \ 'packages' : {
      \   'default' : 0,
      \ },
      \}
let g:tex_conceal = 'abdmg'

if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif
au VimEnter * let g:ycm_semantic_triggers.tex=g:vimtex#re#youcompleteme

autocmd FileType tex set tabstop=2
autocmd FileType tex set shiftwidth=2
autocmd FileType tex set softtabstop=2
autocmd FileType tex set indentexpr=""
autocmd FileType tex set conceallevel=1
autocmd FileType tex :NoMatchParen

"polyglot
let g:polyglot_disabled = ['latex']
let g:python_highlight_space_errors = 0

"vimcmdline
let cmdline_vsplit = 1
let cmdline_in_buffer = 0
let cmdline_map_send = '<space>'
let cmdline_map_send_paragraph = '<C-space>'
nnoremap <F4> :lcd %:p:h<CR>:call VimCmdLineStartApp()<CR>
inoremap <F4> <ESC>:lcd %:p:h<CR>:call VimCmdLineStartApp()<CR>

"semshi
let g:semshi#mark_selected_nodes = 0
let g:semshi#simplify_markup = v:false
let g:semshi#error_sign = v:false

"better whitespace
let g:current_line_whitespace_disabled_soft=1
let g:better_whitespace_ctermcolor=52

"SingleCompile'
let g:SingleCompile_usetee = 0
let g:SingleCompile_usequickfix = 0
noremap <F9> <Esc>:w<CR>:SCCompile<CR>

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

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

"nmap <silent> gD :call CocAction('jumpDefinition', 'vsplit')<CR>
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
nmap <leader>rf <Plug>(coc-refactor)
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>qf  <Plug>(coc-fix-current)

let g:coc_snippet_next = '<C-o>'
let g:coc_snippet_prev = '<C-i>'
imap <C-j> <Plug>(coc-snippets-expand)
"install.packages("languageserver")
let g:coc_global_extensions = [
\    'coc-css',
\    'coc-docker',
\    'coc-emmet',
\    'coc-html',
\    'coc-java',
\    'coc-json',
\    'coc-python',
\    'coc-r-lsp',
\    'coc-snippets',
\    'coc-tsserver',
\    'coc-ultisnips',
\    'coc-vimtex',
\    'coc-yaml'
\]

"Nvim-R
let R_in_buffer = 1
let R_notmuxconf = 1
let R_esc_term = 0
let R_close_term = 1
let R_min_editor_width = -80
autocmd VimEnter * if exists(':RSend') | noremap <space> :call SendParagraphToR('silent', 'down')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap <C-space> :call SendLineToR('down')<CR>| endif
"autocmd VimEnter * if exists(':RSend') | noremap <C-s> :call SendFileToR('silent')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap ZR :call StartR('R')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap ZE :call RQuit('nosave')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap ZH :call RAction('help')<CR>| endif
autocmd VimEnter * if exists(':RSend') | noremap ZV :call RAction('viewdf')<CR>| endif

"argwrap
nnoremap Y :ArgWrap<CR>

"sideways
nnoremap <silent> R :SidewaysLeft<CR>
nnoremap <silent> U :SidewaysRight<CR>

"tagbar
let g:tagbar_autofocus = 1
nnoremap <silent> <F3> :TagbarToggle<CR>
inoremap <silent> <F3> <ESC>:TagbarToggle<CR>

"tmux
if exists('$TMUX')
    function! TmuxOrSplitSwitch(wincmd, tmuxdir)
        let previous_winnr = winnr()
        silent! execute "wincmd " . a:wincmd
        if previous_winnr == winnr()
            call system("tmux select-pane -" . a:tmuxdir)
            redraw!
        endif
    endfunction

    let previous_title = substitute(system("tmux display-message -p '#{pane_title}'"), '\n', '', '')
    let &t_ti = "\<Esc>]2;vim\<Esc>\\" . &t_ti
    let &t_te = "\<Esc>]2;". previous_title . "\<Esc>\\" . &t_te

    nnoremap <silent> <C-h> :call TmuxOrSplitSwitch('h', 'L')<cr>
    nnoremap <silent> <C-j> :call TmuxOrSplitSwitch('j', 'D')<cr>
    nnoremap <silent> <C-k> :call TmuxOrSplitSwitch('k', 'U')<cr>
    nnoremap <silent> <C-l> :call TmuxOrSplitSwitch('l', 'R')<cr>
else
    map <C-h> <C-w>h
    map <C-j> <C-w>j
    map <C-k> <C-w>k
    map <C-l> <C-w>l
endif

"vimux
noremap <leader>vp :VimuxPromptCommand<CR>
noremap <leader>vl :VimuxRunLastCommand<CR>
noremap <leader>vi :VimuxInspectRunner<CR>
noremap <leader>vz :VimuxZoomRunner<CR>

" --------------------------------
" --- End Plugin Configuration ---
" --------------------------------

"spellcheck
let g:myLang = 0
let g:myLangList = ['en_us', 'de_de']
function! MySpellLang()
  let g:myLang = (g:myLang + 1) % (len(g:myLangList) + 1)
  :if g:myLang == 0
    :set nospell
    :echo "nospell"
  :else
    :silent set spell
    :silent let &spelllang=g:myLangList[g:myLang-1]
    :echo "language:" g:myLangList[g:myLang-1]
  :endif
endf
map <F7> :call MySpellLang()<CR>

let g:python_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/bin/python3'

colorscheme monokai-phoenix
set termguicolors
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
set hidden

set updatetime=300
set shortmess+=c
set signcolumn=yes

set backspace=indent,eol,start
set relativenumber
set nobackup
set nowritebackup
set cmdheight=2
set t_Co=256
set ttyfast

noremap Q :qa<CR>
noremap <silent> gs :vsplit<CR>
noremap <silent> gS :split<CR>
noremap <left> <C-W>H
noremap <right> <C-W>L
noremap <up> <C-W>K
noremap <down> <C-W>J
"noremap <C-h> <C-W>h
"noremap <C-j> <C-W>j
"noremap <C-k> <C-W>k
"noremap <C-l> <C-W>l
nnoremap <silent> ö :noh<CR>

vmap < <gv
vmap > >gv

autocmd FileType yaml       set tabstop=2 shiftwidth=2 softtabstop=2 indentexpr=""
autocmd FileType html       set tabstop=2 shiftwidth=2 softtabstop=2 indentexpr=""
autocmd FileType htmldjango set tabstop=2 shiftwidth=2 softtabstop=2 indentexpr=""
autocmd FileType javascript set tabstop=2 shiftwidth=2 softtabstop=2 indentexpr=""

tnoremap <C-h> <C-\><C-n><C-W>h
tnoremap <C-j> <C-\><C-n><C-W>j
tnoremap <C-k> <C-\><C-n><C-W>k
tnoremap <C-l> <C-\><C-n><C-W>l
