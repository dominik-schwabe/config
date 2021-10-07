local fn = vim.fn
local cmd = vim.cmd
local exec =  vim.api.nvim_exec

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

cmd("command! GrepWord Grepper -cword")
cmd("command! SearchInFiles lua SearchFilesRegex()")
