set cmdheight=2

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
"multiple cursors
Plug 'mg979/vim-visual-multi'
"jump fast to location
Plug 'easymotion/vim-easymotion', { 'on': ['<Plug>(easymotion-overwin-f)', '<Plug>(easymotion-overwin-f2)'] }
"improve search
Plug 'haya14busa/vim-asterisk'
"toggle comment
Plug 'preservim/nerdcommenter', { 'on': '<Plug>NERDCommenterToggle' }
"buffer explorer
Plug 'jlanzarotta/bufexplorer'
"change root to git project
Plug 'airblade/vim-rooter'
"substitute brackets with others (cs"')
Plug 'tpope/vim-surround'
"extension of .-command
Plug 'tpope/vim-repeat'
"beautiful statusbar
Plug 'itchyny/lightline.vim'
"colorschemes
Plug 'Reewr/vim-monokai-phoenix'
"better language behavior
Plug 'sheerun/vim-polyglot'
"explore directory
Plug 'preservim/nerdtree', { 'on': ['NERDTree', 'NERDTreeToggle', 'NERDTreeFind'] }
"wrap function arguments
Plug 'foosoft/vim-argwrap', { 'on': 'ArgWrap' }
"swap objects like function arguments
Plug 'AndrewRadev/sideways.vim', { 'on': ['SidewaysLeft', 'SidewaysRight'] }
"textobj extension
Plug 'wellle/targets.vim'
"textobj for indents
Plug 'michaeljsmith/vim-indent-object'
call plug#end()


" ----------------------------------
" --- Begin Plugin Configuration ---
" ----------------------------------

"rooter
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_patterns = ['.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', '>site-packages', 'package.json', 'package-lock.json']

"monokai
let g:monokai_gui_italic = 1
let g:monokai_term_italic = 1

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

"lightline
set laststatus=2

"polyglot
let g:python_highlight_space_errors = 0

"argwrap
nnoremap Y :ArgWrap<CR>

"sideways
nnoremap <silent> R :SidewaysLeft<CR>
nnoremap <silent> U :SidewaysRight<CR>

map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" --------------------------------
" --- End Plugin Configuration ---
" --------------------------------

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

if has("termguicolors") | set termguicolors | endif

syntax on
colorscheme monokai-phoenix
set background=dark
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

noremap Q :qa<CR>
noremap <left> <C-W>H
noremap <right> <C-W>L
noremap <up> <C-W>K
noremap <down> <C-W>J
nnoremap <silent> ö :noh<CR>
noremap <c-g> 2<c-g>

vmap < <gv
vmap > >gv

au FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 indentexpr=""
