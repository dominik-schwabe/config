local fn = vim.fn
local map = vim.api.nvim_set_keymap
local cmd = vim.cmd
local exec =  vim.api.nvim_exec

local def_opt = {noremap = true, silent = true}

cmd([[ runtime plugin/grepper.vim]])
cmd([[ let g:grepper.tools = ['rg', 'git', 'grep'] ]])
cmd([[ let g:grepper.rg.grepprg .= ' -i' ]])
cmd([[ let g:grepper.git.grepprg .= 'i' ]])
cmd([[ let g:grepper.grep.grepprg .= ' -i' ]])
cmd([[ let g:grepper.prompt = 0 ]])
cmd([[ let g:grepper.highlight = 1 ]])
cmd([[ let g:grepper.stop = 1000 ]])

function SearchFilesRegex()
  fn.inputsave()
  local search = fn.input("Search in files: ")
  fn.inputrestore()
  if not (search == "") then
    exec(string.format('Grepper -query "%s"', fn.escape(search, '"')), false)
    fn.histdel("@", -1)
  end
end

map("", "gs", "<plug>(GrepperOperator)", def_opt)
map("n", "<c-_>", ":Grepper -cword<cr>", def_opt)
map("x", "<c-_>", "<plug>(GrepperOperator)", def_opt)
map("n", "_", "<CMD>lua SearchFilesRegex()<CR>", def_opt)
