set cmdheight=2

function MakeDir(path)
  silent call system('mkdir -p ' . a:path)
  return v:shell_error
endfunction

function DownloadWithWget(url, savepath)
  echom 'wget: downloading ' . a:url . ' to ' . a:savepath
  silent call system('wget -O ' . a:savepath . ' ' . a:url)
  return v:shell_error
endfunction

function DownloadWithCurl(url, savepath)
  echom 'curl: downloading ' . a:url . ' to ' . a:savepath
  silent call system('wget -O ' . a:savepath . ' ' . a:url)
  silent call system('curl --create-dirs -fLo ' . a:savepath . ' ' . a:url)
  return v:shell_error
endfunction

function InstallVimPlug()
  let l:dirname = '$HOME/.vim/autoload/'
  let l:path = l:dirname . 'plug.vim'
  if !empty(glob(l:path))
    return
  endif
  let l:url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  echom 'installing plug.vim'
  if MakeDir(l:dirname) != 0
    echom 'failure creating directory ' . l:dirname
    return
  endif
  echom
  if DownloadWithWget(l:url, l:path) == 0 || DownloadWithCurl(l:url, l:path) == 0
    echom 'success downloading plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  else
    echom 'failure downloading plug.vim'
  endif
endfunction

function ExecuteCommand(command, message)
  echom a:message
  silent call system(a:command)
  if v:shell_error != 0
    echom 'failure '. a:message
  endif
  return v:shell_error
endfunction

function InstallRipgrep(version)
  let l:bin_path = '$HOME/bin/'
  let l:executable = 'rg'
  let l:exec_path = l:bin_path . l:executable
  if !empty(glob(l:exec_path))
    return
  endif
  let l:rg_folder_name = 'ripgrep-' . a:version . '-x86_64-unknown-linux-musl'
  let l:rg_archive_name = l:rg_folder_name . '.tar.gz'
  let l:rg_archive_url = 'https://github.com/BurntSushi/ripgrep/releases/download/' . a:version . '/' . l:rg_archive_name
  let l:rg_archive_path = l:bin_path . l:rg_archive_name
  let l:rg_extract_path = l:bin_path . l:rg_folder_name
  let l:rg_extract_path_exec = l:rg_extract_path . '/' . l:executable

  echom 'installing ripgrep'
  if MakeDir(l:bin_path) != 0
    return
  endif
  echom "downloading archive"
  if DownloadWithWget(l:rg_archive_url, l:rg_archive_path) != 0 && DownloadWithCurl(l:rg_archive_url, l:rg_archive_path) != 0
    echom 'failure downloading ripgrep'
    return
  endif
  let command = 'tar -C ' . l:bin_path . ' -xzf ' . l:rg_archive_path
  if ExecuteCommand(command, "extracting archive") != 0
    return
  endif
  let command = 'mv ' . l:rg_extract_path_exec . ' ' . l:exec_path
  if ExecuteCommand(command, "copying ripgrep to bin") != 0
    return
  endif
  let command = 'rm -r ' . l:rg_archive_path . ' ' . l:rg_extract_path
  if ExecuteCommand(command, "cleaning installation") != 0
    return
  endif
endfunction

call InstallVimPlug()
call InstallRipgrep('12.1.1')

"define plugins using vim-plug
call plug#begin('~/.vim/plugged')
"database completion (coc-dadbod)
"Plug 'tpope/vim-dadbod'
"run test
"Plug 'janko/vim-test'
"session handling
"Plug 'tpope/vim-obsession'
"debugger
"Plug 'puremourning/vimspector', { 'do': './install_gadget.py --enable-python', 'on': '<Plug>VimspectorContinue' } git diff on left sidebar
"multiple cursors
Plug 'terryma/vim-multiple-cursors'
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
"xpath
Plug 'actionshrimp/vim-xpath', { 'for': ['html', 'xml'] }
"json pretty print
Plug 'tpope/vim-jdaddy'
"markdown preview ( requires: 'npm -g install instant-markdown-d || pip install --user smdv' )
Plug 'suan/vim-instant-markdown', { 'for': 'markdown'}
"rainbow parenthese
Plug 'luochen1990/rainbow', { 'for': ['python', 'c', 'cpp', 'lisp', 'html', 'vim', 'java'] }
"highlight colorcodes
Plug 'ap/vim-css-color', { 'for': ['html', 'css', 'javascript', 'sh', 'yaml', 'dosini', 'conf', 'cfg', 'vim'] }
"align statements
Plug 'junegunn/vim-easy-align', { 'on': '<Plug>(EasyAlign)' }
"greplike search
Plug 'jremmen/vim-ripgrep', { 'on': 'Rg' }
"completion terms from other tmux pane
Plug 'wellle/tmux-complete.vim'
if $TMUX != ""
    "focus commands work in tmux
    Plug 'tmux-plugins/vim-tmux-focus-events'
    "execute command in tmux pane
    Plug 'benmills/vimux'
endif
"textobj for python
Plug 'jeetsukumaran/vim-pythonsense', { 'for': 'python' }
"toggle comment
Plug 'scrooloose/nerdcommenter', { 'on': '<Plug>NERDCommenterToggle' }
"buffer explorer
Plug 'jlanzarotta/bufexplorer'
"async lint
Plug 'w0rp/ale'
"highlight trailing whitespace
Plug 'bronson/vim-trailing-whitespace'
"change root to git project
Plug 'airblade/vim-rooter'
"fast html writing
Plug 'mattn/emmet-vim', { 'for': ['html', 'javascript'] }
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
Plug 'reewr/vim-monokai-phoenix'
"better language behavior
Plug 'sheerun/vim-polyglot'
"completion
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
"explore directory
Plug 'scrooloose/nerdtree', { 'on': ['NERDTree', 'NERDTreeToggle', 'NERDTreeFind'] }
"git integration with nerdtree
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTree', 'NERDTreeToggle', 'NERDTreeFind'] }
"view concept definitions
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
"super searching
Plug 'junegunn/fzf', { 'on': 'FZF', 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim', { 'on': 'FZF' }
"R ide
Plug 'jalvesaq/Nvim-R', { 'for': 'r' }
"send commands to console
Plug 'jalvesaq/vimcmdline'
"latex ide ( requires: 'pip install neovim-remote' )
Plug 'lervag/vimtex', { 'for': 'latex' }
if has("nvim")
    "semantic highlighting of python code
    Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins', 'for': 'python' }
endif
"compile/run
Plug 'skywind3000/asyncrun.vim', { 'on': ['AsyncRun', 'AsyncStop'] }
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
Plug 'andymass/vim-matchup', { 'for': ['html', 'xml'] }
call plug#end()




" ----------------------------------
" --- Begin Plugin Configuration ---
" ----------------------------------

"vim-rooter
"let g:rooter_use_lcd = 1
let g:rooter_manual_only = 1
autocmd VimEnter * :Rooter

"vim-matchup
let g:matchup_matchparen_enabled = 1

"ListToggle
let g:lt_height = 10
nmap <silent> ä :LToggle<CR>
nmap <silent> Ö :QToggle<CR>

"test-vim
let test#strategy = "asyncrun_background_term"
let test#python#runner = 'pytest'

"easymotion
"nmap Ö <Plug>(easymotion-overwin-f)
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1
nmap m <Plug>(easymotion-overwin-f)
nmap M <Plug>(easymotion-overwin-f2)
vmap m <Plug>(easymotion-overwin-f)
vmap M <Plug>(easymotion-overwin-f2)

"ayncrun
let g:asyncrun_save = 1
let g:asyncrun_open = 10
let g:asyncrun_trim = 1
let g:asyncrun_exit = 'if g:asyncrun_status != "success" | call system("notify-send -t 1000 -u critical \"$VIM_FILENAME\" \"finished with error\"") | else | call system("notify-send -t 1000 -u normal \"$VIM_FILENAME\" \"finished normaly\"") | endif'

let g:asyncrun_status = "success"
function AsyncrunOutput(raw)
    if g:asyncrun_status != "running"
        let asynccommand = ":AsyncRun -program=make -strip=1 "
        call system("notify-send -t 1000 -u normal \"$VIM_FILENAME\" \"start\"")
        if &filetype == "c" || &filetype == "cpp"
            let asynccommand .= " %< && ./%<"
        else
            let asynccommand .= "-raw=" . a:raw . " %"
        endif
        echom l:asynccommand
        execute asynccommand
    else
        :AsyncStop
    endif
endfunction
nmap <silent> Ü :call AsyncrunOutput(0)<CR>
nmap <silent> ü :call AsyncrunOutput(1)<CR>

"vim-asterisk
map *   <Plug>(asterisk-*)
map #   <Plug>(asterisk-#)
map g*  <Plug>(asterisk-g*)
map g#  <Plug>(asterisk-g#)
map z*  <Plug>(asterisk-z*)
map gz* <Plug>(asterisk-gz*)
map z#  <Plug>(asterisk-z#)
map gz# <Plug>(asterisk-gz#)

"vimspector
"nmap <leader>ds <Plug>VimspectorStop
"nmap <leader>dr <Plug>VimspectorRestart
"nmap <leader>dp <Plug>VimspectorPause
"nmap <F5> <Plug>VimspectorContinue
"imap <F5> <ESC><Plug>VimspectorContinue
"nmap <F6> <Plug>VimspectorToggleBreakpoint
"imap <F6> <ESC><Plug>VimspectorToggleBreakpoint
"nmap <S-F6> <Plug>VimspectorAddFunctionBreakpoint
"imap <S-F6> <ESC><Plug>VimspectorAddFunctionBreakpoint
"nmap <F8> <Plug>VimspectorStepOver
"imap <F8> <ESC><Plug>VimspectorStepOver
"<Plug>VimspectorStepInto
"<Plug>VimspectorStepOut

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


"ripgrep
function RgSearch()
  let l:search = input("Search in files: ")
  if l:search != ""
    execute 'Rg ' . '"' . escape(search, '"') . '"'
  endif
endfunction
nnoremap _ :call RgSearch()<CR>
let g:rg_derive_root = 'true'
let g:rg_highlight = 'true'

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
let g:NERDDefaultAlign='start'
nmap gc <Plug>NERDCommenterToggle
vmap gc <Plug>NERDCommenterToggle gv

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
let g:ale_python_auto_pipenv = 1
let g:ale_set_highlights = 0
let g:ale_set_loclist = 1
let g:ale_lint_on_enter = 0
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_text_changed = 0
let g:ale_set_quickfix = 0
let g:ale_open_list = 0
let g:ale_keep_list_window_open = 0
let g:ale_linters = {
\  'python': ['pylint']
\}
let g:ale_fixers = {
\  'python': ['black', 'isort'],
\  'javascript': ['prettier'],
\  'json': ['prettier'],
\  'tex': ['latexindent']
\}
nnoremap <F9> :ALEFix<CR>
inoremap <F9> <ESC>:ALEFix<CR>
autocmd BufWinEnter experiments.py :ALEDisable

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
let g:vimtex_view_skim_reading_bar = 1
let g:vimtex_quickfix_autoclose_after_keystrokes = 2
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
let cmdline_esc_term = 0
let cmdline_vsplit = 1
let cmdline_in_buffer = 1
let cmdline_term_width = 67
let cmdline_map_send = '<space>'
let cmdline_map_send_paragraph = '<C-space>'
let cmdline_map_source_fun = '<LocalLeader><space>'

let cmdline_app = {}
let cmdline_app['python'] = 'ipython'
nnoremap <F4> :lcd %:p:h<CR>:call VimCmdLineStartApp()<CR>
inoremap <F4> <ESC>:lcd %:p:h<CR>:call VimCmdLineStartApp()<CR>

"semshi
let g:semshi#mark_selected_nodes = 0
let g:semshi#simplify_markup = v:false
let g:semshi#error_sign = v:false

"better whitespace
let g:current_line_whitespace_disabled_soft=1
let g:better_whitespace_ctermcolor=52

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
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>qf  <Plug>(coc-fix-current)

let g:coc_snippet_next = '<C-o>'
let g:coc_snippet_prev = '<C-i>'
imap <C-j> <Plug>(coc-snippets-expand)
"install.packages("languageserver")
let g:coc_global_extensions = [
\  'coc-css',
\  'coc-docker',
\  'coc-emmet',
\  'coc-github-users',
\  'coc-html',
\  'coc-java',
\  'coc-json',
\  'coc-prettier',
\  'coc-python',
\  'coc-r-lsp',
\  'coc-sh',
\  'coc-snippets',
\  'coc-tsserver',
\  'coc-ultisnips',
\  'coc-vimlsp',
\  'coc-vimtex',
\  'coc-yaml',
\  'coc-clangd',
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

"zoomwintab
let g:zoomwintab_remap = 0

"eregex.vim
let g:eregex_default_enable = 0

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


let g:python_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/bin/python3'

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
set hidden

set updatetime=300
set shortmess+=c
set signcolumn=yes

set background=dark
set backspace=indent,eol,start
set relativenumber
set nobackup
set nowritebackup
set t_Co=256
set ttyfast

noremap <F12> :ZoomWinTabToggle<CR>
inoremap <F12> <ESC>:ZoomWinTabToggle<CR>
noremap Q :qa<CR>
noremap <C-q> :qa!<CR>
noremap <silent> gs :vsplit<CR>
noremap <silent> gS :split<CR>
noremap <left> <C-W>H
noremap <right> <C-W>L
noremap <up> <C-W>K
noremap <down> <C-W>J
nnoremap <silent> ö :noh<CR>

vmap < <gv
vmap > >gv

let PYTHONUNBUFFERED=1
let $PYTHONUNBUFFERED=1
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

autocmd FileType yaml       set tabstop=2 shiftwidth=2 softtabstop=2 indentexpr=""
autocmd FileType html       set tabstop=2 shiftwidth=2 softtabstop=2 indentexpr=""
autocmd FileType htmldjango set tabstop=2 shiftwidth=2 softtabstop=2 indentexpr=""
autocmd FileType javascript set tabstop=2 shiftwidth=2 softtabstop=2 indentexpr=""
autocmd FileType vim        set tabstop=2 shiftwidth=2 softtabstop=2 indentexpr=""

tnoremap <C-h> <C-\><C-n><C-W>h
tnoremap <C-j> <C-\><C-n><C-W>j
tnoremap <C-k> <C-\><C-n><C-W>k
tnoremap <C-l> <C-\><C-n><C-W>l
tnoremap <silent> <F2> <C-\><C-n>:ToggleBufExplorer<CR>
tnoremap <F12> <C-\><C-n>:ZoomWinTabToggle<CR>
if has("nvim")
  set termguicolors
  au TermOpen * set nonumber norelativenumber signcolumn=no
  autocmd TermOpen,BufWinEnter,WinEnter term://* startinsert
  autocmd TermClose term://* :execute "bdelete! " . expand("<abuf>")
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
