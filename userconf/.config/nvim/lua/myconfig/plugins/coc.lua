local api = vim.api
local cmd = vim.cmd
local g = vim.g
local fn = vim.fn
local map = api.nvim_set_keymap

local def_opt = { noremap = true, silent = true }
local nore_opt = { noremap = true }
local silent_opt = { silent = true }

local feedkey = function(key, mode)
  api.nvim_feedkeys(api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

g.coc_global_extensions = require("myconfig.config").coc_extensions

local function check_back_space()
  local col = fn.col(".") - 1
  return (col == 0) or (fn.getline("."):sub(col, col):match("%s") ~= nil)
end

function Tab()
  if fn.pumvisible() == 1 then
    feedkey("<C-n>", "n")
  else
    if check_back_space() then
      feedkey("<TAB>", "n")
    else
      fn["coc#refresh"]()
    end
  end
end

function S_Tab()
  if fn.pumvisible() == 1 then
    feedkey("<C-p>", "n")
  else
    feedkey("<C-h>", "n")
  end
end

map("i", "<TAB>", "<CMD>lua Tab()<CR>", def_opt)
map("i", "<S-TAB>", "<CMD>lua S_Tab()<CR>", def_opt)
-- map("i", "<c-space>", "call coc#refresh()", def_opt)

cmd([[inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]])

map("n", "[g", "<Plug>(coc-diagnostic-prev)", {})
map("n", "]g", "<Plug>(coc-diagnostic-next)", {})

map("n", "gd", "<Plug>(coc-definition)", {})
map("n", "gy", "<Plug>(coc-type-definition)", {})
map("n", "gi", "<Plug>(coc-implementation)", {})
map("n", "gr", "<Plug>(coc-references)", {})

cmd([[nnoremap <silent> K :call Show_documentation()<CR>]])

cmd([[function! Show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction]])

cmd([[autocmd CursorHold * silent call CocActionAsync('highlight')]])
cmd([[nmap <space>rn <Plug>(coc-rename)]])

-- cmd([[xmap <leader>f <Plug>(coc-format-selected)]])
-- cmd([[nmap <leader>f <Plug>(coc-format-selected)]])

cmd([[augroup mygroup
  autocmd!
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end]])

cmd([[xmap <space>a  <Plug>(coc-codeaction-selected)]])
cmd([[nmap <space>a  <Plug>(coc-codeaction-selected)]])

cmd([[nmap <space>ca  <Plug>(coc-codeaction)]])
cmd([[nmap <space>qf  <Plug>(coc-fix-current)]])

cmd([[nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"]])
cmd([[nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"]])
cmd([[inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"]])
cmd([[inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"]])
cmd([[vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"]])
cmd([[vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"]])

cmd([[nmap <silent> <C-s> <Plug>(coc-range-select)]])
cmd([[xmap <silent> <C-s> <Plug>(coc-range-select)]])

cmd([[command! -nargs=0 Format :call CocAction('format')]])
cmd([[command! -nargs=? Fold :call   CocAction('fold', <f-args>)]])
cmd([[command! -nargs=0 OR :call     CocAction('runCommand', 'editor.action.organizeImport')]])

-- cmd([[nnoremap <silent><nowait> <space>f <CMD>Format<CR>]])
-- nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
-- nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
-- nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
-- nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
-- nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
-- nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
-- nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
-- nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
