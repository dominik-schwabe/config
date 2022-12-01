set t_Co=256
let &t_SI="\e[6 q"
let &t_EI="\e[2 q"
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
if has("termguicolors") | set termguicolors | endif
syntax on

set cmdheight=1

if $MINIMAL_CONFIG == ""
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

    call plug#begin('~/.vim/plugged')
    "improve search
    Plug 'haya14busa/vim-asterisk'
    "toggle comment
    Plug 'preservim/nerdcommenter', { 'on': '<Plug>NERDCommenterToggle' }
    "buffer explorer
    Plug 'jlanzarotta/bufexplorer'
    "change root based on path patterns
    Plug 'airblade/vim-rooter'
    "substitute brackets with others
    Plug 'tpope/vim-surround'
    "better language behavior
    Plug 'sheerun/vim-polyglot'
    "explore directory
    Plug 'preservim/nerdtree', { 'on': ['NERDTree', 'NERDTreeToggle', 'NERDTreeFind'] }
    "wrap function arguments
    Plug 'foosoft/vim-argwrap', { 'on': 'ArgWrap' }
    "textobj extension
    Plug 'wellle/targets.vim'
    call plug#end()


    " ----------------------------------
    " --- Begin Plugin Configuration ---
    " ----------------------------------

    "rooter
    let g:rooter_change_directory_for_non_project_files = 'current'
    let g:rooter_patterns = ['>nvim', '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', '>site-packages', 'package.json', 'package-lock.json']

    "vim-asterisk
    map *   <Plug>(asterisk-*)
    map #   <Plug>(asterisk-#)
    map g*  <Plug>(asterisk-g*)
    map g#  <Plug>(asterisk-g#)
    map z*  <Plug>(asterisk-z*)
    map gz* <Plug>(asterisk-gz*)
    map z#  <Plug>(asterisk-z#)
    map gz# <Plug>(asterisk-gz#)

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

    "polyglot
    let g:python_highlight_space_errors = 0

    "argwrap
    nnoremap Y :ArgWrap<CR>

    " --------------------------------
    " --- End Plugin Configuration ---
    " --------------------------------


    au FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 indentexpr=""
endif

colorscheme industry
hi CursorLine cterm=NONE ctermbg=333 guibg=#303030
hi Visual cterm=NONE ctermbg=444 guibg=#444444 guifg=NONE
hi CursorLineNr term=none cterm=none gui=none

set splitbelow
set splitright
set cursorline

set number
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
set diffopt+=vertical

set backspace=indent,eol,start
set relativenumber
set nobackup
set nowritebackup
set ttyfast
set incsearch
set hlsearch
set modeline

au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

noremap gw :write<CR>
noremap Q :qa<CR>
noremap <left> <C-W>H
noremap <right> <C-W>L
noremap <up> <C-W>K
noremap <down> <C-W>J
nnoremap <silent> ö :noh<CR>
noremap <c-g> 2<c-g>

map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

vmap < <gv
vmap > >gv

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


" --------------------------
" --- vim-sensible start ---
" --------------------------


" Allow backspace in insert mode.
if &backspace == ""
  set backspace=indent,eol,start
endif

" Allow for mappings including `Esc`, while preserving
" zero timeout after pressing it manually.
" (only vim needs a fix for this)
if !has('nvim') && &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=100
endif

" Set default whitespace characters when using `:set list`
if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

" Delete comment character when joining commented lines
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j
endif

" Search upwards for tags file instead only locally
if has('path_extra')
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif

" Fix issues with fish shell
" https://github.com/tpope/vim-sensible/issues/50
if &shell =~# 'fish$' && (v:version < 704 || v:version == 704 && !has('patch276'))
  set shell=/usr/bin/env\ bash
endif

" Increase history size to 1000 items.
if &history < 1000
  set history=1000
endif

" Allow for up to 50 opened tabs on Vim start.
if &tabpagemax < 50
  set tabpagemax=50
endif

" Reduce updatetime from 4000 to 300 to avoid issues with coc.nvim
if &updatetime == 4000
  set updatetime=300
endif

" Automatically reload file if changed somewhere else
redir => capture
silent autocmd CursorHold
redir END
if match(capture, 'checktime') == -1
  augroup polyglot-sensible
    au!
    au CursorHold * silent! checktime
  augroup END
endif

" Always save upper case variables to viminfo file.
if !empty(&viminfo)
  set viminfo^=!
endif

" Don't save options in sessions and views
set sessionoptions-=options
set viewoptions-=options

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^Eterm'
  set t_Co=16
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

" `Ctrl-U` in insert mode deletes a lot. Use `Ctrl-G` u to first break undo,
" so that you can undo `Ctrl-U` without undoing what you typed before it.
if empty(mapcheck('<C-U>', 'i'))
  inoremap <C-U> <C-G>u<C-U>
endif

if empty(mapcheck('<C-W>', 'i'))
  inoremap <C-W> <C-G>u<C-W>
endif


" ------------------------
" --- vim-sensible end ---
" ------------------------
