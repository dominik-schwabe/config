set cmdheight=2
let g:polyglot_disabled = ['latex', 'tex']

function InstallPluginManager()
  let l:directory = '$HOME/.vim/autoload/'
  let l:path = l:directory . 'plug.vim'
  if !empty(glob(l:path)) | return | endif
  let l:url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  echom 'installing plugin manager'
  silent call system('mkdir -p ' . l:directory)
  if v:shell_error | echom 'failure creating directory for plugin manager'  | return | endif
  silent call system('curl --create-dirs -fLo ' . l:path . ' ' . l:url)
  if v:shell_error | silent call system('wget -O ' . l:path . ' ' . l:url) | endif
  if v:shell_error | echom 'failure installing plugin manager' | return | endif
  echom 'success installing plugin manager'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endfunction

call InstallPluginManager()

"define plugins using vim-plug
call plug#begin('~/.vim/plugged')
"heuristically set buffer options
" Plug 'tpope/vim-sleuth'
"greplike search
Plug 'mhinz/vim-grepper'
"html expansion
Plug 'mattn/emmet-vim'
"multiple cursors
Plug 'mg979/vim-visual-multi'
"perl/ruby like regex
Plug 'othree/eregex.vim'
"git status bar
Plug 'airblade/vim-gitgutter'
"toggle quickfix, loclist
Plug 'Valloric/ListToggle', { 'on': ['LToggle', 'QToggle'] }
"jump fast to location
Plug 'easymotion/vim-easymotion', { 'on': ['<Plug>(easymotion-overwin-f)', '<Plug>(easymotion-overwin-f2)'] }
"like tmux zoom
Plug 'troydm/zoomwintab.vim', { 'on': 'ZoomWinTabToggle' }
"improve search
Plug 'haya14busa/vim-asterisk'
"markdown preview ( requires: 'npm -g install instant-markdown-d || pip install --user smdv' )
Plug 'suan/vim-instant-markdown', { 'for': 'markdown'}
"rainbow parenthese
Plug 'luochen1990/rainbow', { 'for': ['python', 'c', 'cpp', 'lisp', 'html', 'vim', 'java'] }
"highlight colorcodes
Plug 'norcalli/nvim-colorizer.lua'
"completion terms from other tmux pane
Plug 'wellle/tmux-complete.vim'
"focus commands work in tmux
Plug 'christoomey/vim-tmux-navigator'
"textobj for python
Plug 'jeetsukumaran/vim-pythonsense', { 'for': 'python' }
"toggle comment
Plug 'preservim/nerdcommenter', { 'on': '<Plug>NERDCommenterToggle' }
"buffer explorer
Plug 'jlanzarotta/bufexplorer'
"async lint
Plug 'w0rp/ale'
"highlight trailing whitespace
Plug 'bronson/vim-trailing-whitespace'
"change root to git project
Plug 'airblade/vim-rooter'
"substitute brackets with others (cs"')
Plug 'tpope/vim-surround'
"extension of .-command
Plug 'tpope/vim-repeat'
"git wrapper
Plug 'tpope/vim-fugitive'
"beautiful statusbar
Plug 'itchyny/lightline.vim'
"snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
"colorschemes
Plug 'crusoexia/vim-monokai'
"better language behavior
Plug 'sheerun/vim-polyglot'
"completion
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
"explore directory
Plug 'preservim/nerdtree', { 'on': ['NERDTree', 'NERDTreeToggle', 'NERDTreeFind'] }
"git integration with nerdtree
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTree', 'NERDTreeToggle', 'NERDTreeFind'] }
"view concept definitions
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
"super searching
Plug 'junegunn/fzf', { 'on': 'FZF' }
Plug 'junegunn/fzf.vim', { 'on': 'FZF' }
"R ide
"send commands to console
Plug 'urbainvaes/vim-ripple'
"latex ide ( requires: 'pip install neovim-remote' )
Plug 'lervag/vimtex'
if has("nvim")
    "semantic highlighting for python
    Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins', 'for': 'python' }
endif
"semantic highlighting for c/c++
Plug 'jackguo380/vim-lsp-cxx-highlight'
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
Plug 'andymass/vim-matchup'
"faster merge line
Plug 'AndrewRadev/splitjoin.vim'
call plug#end()



" ----------------------------------
" --- Begin Plugin Configuration ---
" ----------------------------------

"rooter
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_patterns = ['.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', '>site-packages']

"monokai
let g:monokai_gui_italic = 1
let g:monokai_term_italic = 1

"vim-matchup
let g:matchup_matchparen_enabled = 1

"ListToggle
let g:lt_height = 10
nmap <silent> ä :LToggle<CR>
nmap <silent> Ö :QToggle<CR>

"easymotion
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1
nmap m <Plug>(easymotion-overwin-f)
nmap M <Plug>(easymotion-overwin-f2)
vmap m <Plug>(easymotion-overwin-f)
vmap M <Plug>(easymotion-overwin-f2)

"vim-asterisk
map *   <Plug>(asterisk-*)
map #   <Plug>(asterisk-#)
map g*  <Plug>(asterisk-g*)
map g#  <Plug>(asterisk-g#)
map z*  <Plug>(asterisk-z*)
map gz* <Plug>(asterisk-gz*)
map z#  <Plug>(asterisk-z#)
map gz# <Plug>(asterisk-gz#)

"pythonsense
let g:is_pythonsense_suppress_motion_keymaps = 1

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


"vim-grepper
function SearchFilesRegex()
  call inputsave()
  let l:search = input("Search in files: ")
  call inputrestore()
  if !empty(l:search)
    exec "Grepper -query '" . l:search . "'"
    call histdel("@", -1)
  endif
endfunction

nnoremap _ :call SearchFilesRegex()<cr>
if !empty(globpath(&rtp, '/plugin/grepper.vim'))
  runtime plugin/grepper.vim
  let g:grepper.tools = ['rg', 'git', 'grep']
  let g:grepper.rg.grepprg .= ' -i'
  let g:grepper.git.grepprg .= 'i'
  let g:grepper.grep.grepprg .= ' -i'
  let g:grepper.prompt = 0
  let g:grepper.highlight = 1
  let g:grepper.stop = 1000
  nmap gs <plug>(GrepperOperator)
  xmap gs <plug>(GrepperOperator)
  nnoremap <c-_> :Grepper -cword<cr>
  xmap <c-_> <plug>(GrepperOperator)
endif

"NERDTree
let NERDTreeQuitOnOpen=1
let NERDTreeMinimalUI = 1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | :wincmd h | endif
let g:NERDTreeIgnore = ['__pycache__']
nnoremap <silent> <F1> :NERDTreeToggle<CR>
inoremap <silent> <F1> <ESC>:NERDTreeToggle<CR>
tnoremap <silent> <F1> <C-\><C-n>:NERDTreeToggle<CR>
nnoremap <silent> gt :NERDTreeFind<CR>

"NERDCommenter
let g:NERDCreateDefaultMappings = 0
let g:NERDDefaultAlign='start'
let g:NERDSpaceDelims = 1
nmap gc <Plug>NERDCommenterToggle
vmap gc <Plug>NERDCommenterToggle\|gv

"bufexplorer
let g:bufExplorerDefaultHelp=0
let g:bufExplorerDetailedHelp=0
let g:bufExplorerFindActive=1
let g:bufExplorerShowDirectories=0
let g:bufExplorerShowNoName=0
let g:bufExplorerShowRelativePath=1
let g:bufExplorerShowTabBuffer=1
let g:bufExplorerShowUnlisted=0
let g:bufExplorerSortBy='mru'
let g:bufExplorerSplitBelow=1
let g:bufExplorerSplitRight=1
let g:bufExplorerDisableDefaultKeyMapping=1
nmap <silent> <F2> :ToggleBufExplorer<CR>
imap <silent> <F2> <ESC>:ToggleBufExplorer<CR>

"ale
let g:ale_disable_lsp = 1
let g:ale_python_auto_pipenv = 1
let g:ale_set_highlights = 0
let g:ale_set_loclist = 1
let g:ale_lint_on_enter = 0
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_text_changed = 0
let g:ale_set_quickfix = 0
let g:ale_open_list = 0
let g:ale_keep_list_window_open = 0
let g:ale_languagetool_options = "-l de -d COMMA_PARENTHESIS_WHITESPACE,TYPOGRAFISCHE_ANFUEHRUNGSZEICHEN,DE_CASE,ZB_ABK,F_ANSTATT_PH,LEERZEICHEN_HINTER_DOPPELPUNKT,TEST_F_ANSTATT_PH,EINHEIT_LEERZEICHEN"
let b:ale_linter_aliases = {'tex': ['tex', 'text']}
let g:ale_linters = {
\  'python': ['pylint'],
\  'tex': ['chktex']
\}
let g:ale_fixers = {
\  'python': ['black', 'isort'],
\  'r': ['styler'],
\  'sh': ['shfmt'],
\  'markdown': ['prettier'],
\  'javascript': ['prettier', 'eslint'],
\  'html': ['prettier'],
\  'css': ['prettier'],
\  'json': ['prettier'],
\  'yaml': ['prettier'],
\  'tex': ['latexindent'],
\  'cpp': ['clang-format'],
\  'c': ['clang-format']
\}
nnoremap <F9> :ALEFix<CR>
inoremap <F9> <ESC>:ALEFix<CR>

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
let g:vimtex_view_skim_reading_bar = 1
let g:vimtex_quickfix_autoclose_after_keystrokes = 2
let g:vimtex_quickfix_open_on_warning = 0
"let g:vimtex_quickfix_ignore_filters = ['overfull', 'underfull']
let g:tex_conceal = 'abdmg'

if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif

autocmd FileType tex setlocal conceallevel=1
autocmd FileType tex :NoMatchParen

"polyglot
let g:python_highlight_space_errors = 0

"semshi
let g:semshi#mark_selected_nodes = 0
let g:semshi#simplify_markup = v:false
let g:semshi#error_sign = v:false

"better whitespace
let g:current_line_whitespace_disabled_soft=1
let g:better_whitespace_ctermcolor=52

"coc.nvim
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
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

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

nmap <leader>rn <Plug>(coc-rename)
nmap <leader>rf <Plug>(coc-refactor)
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>qf  <Plug>(coc-fix-current)

command! -nargs=0 Format :call CocAction('format')
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

let g:coc_snippet_next = '<C-o>'
let g:coc_snippet_prev = '<C-i>'
imap <C-j> <Plug>(coc-snippets-expand)

"install.packages("languageserver")
let g:coc_global_extensions = [
\  'coc-clangd',
\  'coc-css',
\  'coc-emmet',
\  'coc-docker',
\  'coc-html',
\  'coc-java',
\  'coc-json',
\  'coc-prettier',
\  'coc-pyright',
\  'coc-r-lsp',
\  'coc-sh',
\  'coc-snippets',
\  'coc-tsserver',
\  'coc-ultisnips',
\  'coc-vimlsp',
\  'coc-vimtex',
\  'coc-yaml',
\]


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

"zoomwintab
let g:zoomwintab_remap = 0

"eregex.vim
let g:eregex_default_enable = 0

"vim-ripple
let g:ripple_term_name = "term:// ripple"
let g:ripple_repls = {
\ "javascript": "node",
\}

let g:ripple_enable_mappings = 0

function SendParagraph()
    let i = line(".")
    let c = col(".")
    let max = line("$")
    let j = i
    let res = i
    let line = substitute(getline(i), "\t", repeat(" ", &tabstop), "g")
    let indentation_of_first_line = strlen(substitute(line, "^\\( *\\).*$", "\\1", "g"))
    let last_was_empty = 0
    while j < max
        let j += 1
        let line = getline(j)
        if line =~ '^\s*$'
          let last_was_empty = 1
        else
          let line = substitute(line, "\t", repeat(" ", &tabstop), "g")
          if last_was_empty == 1 && strlen(substitute(line, "^\\( *\\).*$", "\\1", "g")) <= indentation_of_first_line
            break
          endif
          let res = j
          let last_was_empty = 0
        endif
    endwhile
    let lines = join(filter(getline(i, res), "v:val !~ '^\\s*$'"), "\<cr>")
    if len(lines)
      let lastline = substitute(getline(res), "\t", repeat(" ", &tabstop), "g")
      echom getline(res)
      if strlen(substitute(lastline, "^\\( *\\).*$", "\\1", "g")) > indentation_of_first_line
        let lines .= "\<cr>"
      endif
      call ripple#command("", "", lines)
    endif
    if j < max
        call cursor(j, 1)
    else
        call cursor(max, 1)
    endif
endfunction

function SendSelection()
  let lines = filter(getline("'<", "'>"), "v:val !~ '^\\s*$'")
  if len(lines)
    let num_last_line_string = strlen(substitute(lines[-1], "^\\(\\s*\\).*$", "\\1", "g"))
    echom num_last_line_string
    let lines = join(lines, "\<cr>")
    if num_last_line_string != 0 | let lines .= "\<cr>" | endif
    call ripple#command("", "", lines)
  endif
endfunction

function StartRepl()
  nmap <space> <Plug>(ripple_send_line)j
  vmap <space> :<c-u>call SendSelection()<cr>
  nmap <C-space> :<c-u>call SendParagraph()<cr>
  xmap <localleader><space> <Plug>(ripple_send_buffer)
  call ripple#open_repl(1)
endfunction

nmap <F4> :call StartRepl()<cr>

" --------------------------------
" --- End Plugin Configuration ---
" --------------------------------




"spellcheck
let g:myLang = 0
let g:myLangList = ['en_us', 'de_de']
function! MySpellLang()
  let g:myLang = (g:myLang + 1) % (len(g:myLangList) + 1)
  if g:myLang == 0
    set nospell
    echo "nospell"
  else
    silent set spell
    silent let &spelllang=g:myLangList[g:myLang-1]
    echo "language:" g:myLangList[g:myLang-1]
  endif
endf
nnoremap <F7> :call MySpellLang()<CR>
inoremap <F7> <ESC>:call MySpellLang()<CR>

"toggle terminal
let g:term_buf = 0
let g:term_win = 0

function! Term_toggle(height)
    if win_gotoid(g:term_win)
        hide
    else
        botright new
        exec "resize " . a:height
        try
            exec "buffer " . g:term_buf
        catch
            call termopen($SHELL, {"detach": 0})
            let g:term_buf = bufnr("")
            set nobuflisted
        endtry
        startinsert!
        let g:term_win = win_getid()
    endif
endfunction
nnoremap <silent> <F10> :call Term_toggle(10)<cr>
inoremap <silent> <F10> <ESC>:call Term_toggle(10)<cr>
tnoremap <silent> <F10> <C-\><C-n>:call Term_toggle(10)<cr>


"smart resize
function MyResize(dir)
    let hwin = winnr("h")
    let kwin = winnr("k")
    let lwin = winnr("l")
    let jwin = winnr("j")

    if hwin != lwin
        if a:dir == 0
            vertical resize +5
        else
            vertical resize -5
        endif
    elseif kwin != jwin
        if a:dir == 0
            resize +1
        else
            resize -1
        endif
    endif
endfunction
nnoremap <silent> + :call MyResize(0)<CR>
nnoremap <silent> - :call MyResize(1)<CR>

vnoremap p "_dP

let g:loaded_python_provider = 0
let g:loaded_ruby_provider = 0

let g:python3_host_prog = '/usr/bin/python3'
if $ASDF_DIR != "" && !empty(glob($ASDF_DIR . '/shims/python3'))
  let g:python3_host_prog = $ASDF_DIR . '/shims/python3'
endif

if (has("nvim")) | let $NVIM_TUI_ENABLE_TRUE_COLOR=1 | endif
if (has("termguicolors")) | set termguicolors | endif

colorscheme monokai
set background=dark
set t_Co=256
syntax on
if has("nvim")
  hi LineNr guibg=none
  hi Normal guibg=none
  hi SignColumn guibg=none
endif
hi clear Conceal

set splitbelow
set splitright

set number
set cursorline
set ignorecase

set tabstop=2
set shiftwidth=2
set softtabstop=2
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
set ttyfast

au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

noremap <F12> :ZoomWinTabToggle<CR>
inoremap <F12> <ESC>:ZoomWinTabToggle<CR>
noremap Q :qa<CR>
" noremap <silent> gs :vnew<CR>
" noremap <silent> gS :new<CR>
noremap <left> <C-W>H
noremap <right> <C-W>L
noremap <up> <C-W>K
noremap <down> <C-W>J
nnoremap <silent> ö :noh<CR>
noremap <c-g> 1<c-g>

vmap < <gv
vmap > >gv

let PYTHONUNBUFFERED=1
let $PYTHONUNBUFFERED=1

au FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 indentexpr=""

function TermGoDirection(dir)
  echo winnr(a:dir)
  if winnr() != winnr(a:dir)
    let b:term_was_insert = 1
  else
    let b:term_was_insert = 0
  endif
  exec "normal \<C-W>" . a:dir
endfunction

tnoremap <silent> <C-h> <C-\><C-n>:call TermGoDirection("h")<cr>
tnoremap <silent> <C-j> <C-\><C-n>:call TermGoDirection("j")<cr>
tnoremap <silent> <C-k> <C-\><C-n>:call TermGoDirection("k")<cr>
tnoremap <silent> <C-l> <C-\><C-n>:call TermGoDirection("l")<cr>
tnoremap <silent> <F2> <C-\><C-n>:ToggleBufExplorer<CR>
tnoremap <silent> <F12> <C-\><C-n>:ZoomWinTabToggle<CR>i

if has("nvim")
  au TermOpen * setlocal nonumber norelativenumber signcolumn=no
  au BufEnter term://* if !exists('b:term_was_insert') | let b:term_was_insert = 1 | endif
  au BufEnter term://* if get(b:, "term_was_insert", 1) == 1 | startinsert | endif
  au TermClose term://* exec "bwipeout! " . expand("<abuf>")
endif

"terminal colors
let g:terminal_color_0  = '#000000'
let g:terminal_color_1  = '#ff0000'
let g:terminal_color_2  = '#3fff3f'
let g:terminal_color_3  = '#ed9d12'
let g:terminal_color_4  = '#5f87af'
let g:terminal_color_5  = '#f92782'
let g:terminal_color_6  = '#66d9ef'
let g:terminal_color_7  = '#f8f8f2'
let g:terminal_color_8  = '#ff0000'
let g:terminal_color_9  = '#ff3f3f'
let g:terminal_color_10 = '#3fff3f'
let g:terminal_color_11 = '#deed12'
let g:terminal_color_12 = '#5f87af'
let g:terminal_color_13 = '#f92672'
let g:terminal_color_14 = '#66d9ef'
let g:terminal_color_15 = '#f8f8f2'

function LatexSubstitude()
  %s/\v\$.{-}\$/Udo/ge
  %s/\v\\ref\{.{-}\}/eins/ge
  %s/\v\\cite\{.{-}\}//ge
  %s/\v\\.{-}\{.{-}\}/Udo/ge
  %s/\v[ ]+.{-}\{.{-}\}/Udo/ge
  %s/\v ?\\//ge
  %s/\v +\././ge
  %s/\v +\,/,/ge
  %s/\v[^a-zA-Z0-9üäöß.?!(),]/ /ge
  %s/\v +/ /ge
endfunction

" latex clean text for grammar check
noremap <silent> gl :silent call LatexSubstitude()<cr>
nnoremap db dvb

"nvim-colorizer
if has("nvim")
  lua require'colorizer'.setup()
endif
