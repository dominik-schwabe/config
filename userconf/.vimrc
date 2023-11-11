set t_Co=256
let &t_SI="\e[6 q"
let &t_EI="\e[2 q"
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

augroup myCmds
au!
autocmd VimEnter * silent !echo -ne "\e[2 q"
augroup END

if has("termguicolors") | set termguicolors | endif
syntax on

set cmdheight=1

filetype plugin indent on
colorscheme industry " murphy habamax quiet delek
hi clear Conceal
hi EndOfBuffer  ctermbg=NONE guibg=NONE               cterm=NONE term=NONE
hi Normal       ctermbg=NONE guibg=NONE               cterm=NONE term=NONE
hi SignColumn   ctermbg=NONE guibg=NONE               cterm=NONE term=NONE
hi LineNr       ctermbg=NONE guibg=NONE               cterm=NONE term=NONE
hi CursorLine   ctermbg=NONE guibg=#303030            cterm=NONE term=NONE
hi Visual       ctermbg=NONE guibg=#444444 guifg=NONE cterm=NONE term=NONE
hi CursorLineNr term=NONE cterm=NONE gui=NONE

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
set shiftround

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
set list
set virtualedit=block
set breakindent

if exists('splitkeep')
  set splitkeep=screen
endif

au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

noremap gw :write<CR>
noremap Q :qa<CR>
nnoremap <silent> ö :noh<CR>
noremap <c-g> 2<c-g>
tnoremap <C-e> <C-\><C-n>
noremap <left> :wincmd H<CR>
noremap <right> :wincmd L<CR>
noremap <up> :wincmd K<CR>
noremap <down> :wincmd J<CR>
noremap <space>tw :set wrap!\|echo 'wrap ='&wrap<CR>
noremap <space>tp :set paste!\|echo 'paste ='&paste<CR>
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'
nnoremap db dvb
nnoremap dB dvB
nnoremap cb cvb
nnoremap cB cvB
nnoremap yb yvb
nnoremap yB yvB

noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

noremap < <<
noremap > >>
vnoremap < <gv
vnoremap > >gv

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
  set listchars=extends:>,precedes:<,nbsp:␣,tab:>-,trail:_,nbsp:+
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
