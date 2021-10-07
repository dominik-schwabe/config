local cmd = vim.cmd

cmd([[let g:coc_global_extensions = ['coc-clangd', 'coc-css', 'coc-emmet', 'coc-docker', 'coc-html', 'coc-java', 'coc-json', 'coc-prettier', 'coc-pyright', 'coc-r-lsp', 'coc-sh', 'coc-snippets', 'coc-tsserver', 'coc-ultisnips', 'coc-vimlsp', 'coc-vimtex', 'coc-yaml'] ]])
cmd([[inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : Check_back_space() ? "\<TAB>" : coc#refresh()]])
cmd([[inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"]])
cmd([[function! Check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction]])
cmd([[inoremap <silent><expr> <c-space> coc#refresh()]])

cmd([[inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]])

cmd([[nmap <silent> [g <Plug>(coc-diagnostic-prev)]])
cmd([[nmap <silent> ]g <Plug>(coc-diagnostic-next)]])

cmd([[nmap <silent> gd <Plug>(coc-definition)]])
cmd([[nmap <silent> gy <Plug>(coc-type-definition)]])
cmd([[nmap <silent> gi <Plug>(coc-implementation)]])
cmd([[nmap <silent> gr <Plug>(coc-references)]])

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

cmd([[xmap <leader>f <Plug>(coc-format-selected)]])
cmd([[nmap <leader>f <Plug>(coc-format-selected)]])

cmd([[augroup mygroup
  autocmd!
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end]])

cmd([[xmap <leader>a  <Plug>(coc-codeaction-selected)]])
cmd([[nmap <leader>a  <Plug>(coc-codeaction-selected)]])

cmd([[nmap <leader>ac  <Plug>(coc-codeaction)]])
cmd([[nmap <leader>qf  <Plug>(coc-fix-current)]])

cmd([[xmap if <Plug>(coc-funcobj-i)]])
cmd([[omap if <Plug>(coc-funcobj-i)]])
cmd([[xmap af <Plug>(coc-funcobj-a)]])
cmd([[omap af <Plug>(coc-funcobj-a)]])
cmd([[xmap ic <Plug>(coc-classobj-i)]])
cmd([[omap ic <Plug>(coc-classobj-i)]])
cmd([[xmap ac <Plug>(coc-classobj-a)]])
cmd([[omap ac <Plug>(coc-classobj-a)]])

cmd([[nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"]])
cmd([[nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"]])
cmd([[inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"]])
cmd([[inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"]])
cmd([[vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"]])
cmd([[vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"]])

cmd([[nmap <silent> <C-s> <Plug>(coc-range-select)]])
cmd([[xmap <silent> <C-s> <Plug>(coc-range-select)]])

cmd([[command! -nargs=0 Format :call CocAction('format')]])

cmd([[command! -nargs=? Fold :call     CocAction('fold', <f-args>)]])

cmd([[command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')]])

cmd([[nnoremap <silent><nowait> <space>f <CMD>Format<CR>]])
-- nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
-- nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
-- nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
-- nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
-- nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
-- nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
-- nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
-- nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
