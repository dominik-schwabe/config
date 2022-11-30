set t_Co=256
let &t_SI="\e[6 q"
let &t_EI="\e[2 q"
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
