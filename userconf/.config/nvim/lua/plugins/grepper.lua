local fn = vim.fn
local cmd = vim.cmd
local exec = vim.api.nvim_exec

local get_visual_selection = require("utils").get_visual_selection

cmd([[ runtime plugin/grepper.vim]])
cmd([[ let g:grepper.tools = ['rg', 'git', 'grep'] ]])
cmd([[ let g:grepper.rg.grepprg .= ' -i' ]])
cmd([[ let g:grepper.git.grepprg .= 'i' ]])
cmd([[ let g:grepper.grep.grepprg .= ' -i' ]])
cmd([[ let g:grepper.prompt = 0 ]])
cmd([[ let g:grepper.highlight = 1 ]])
cmd([[ let g:grepper.stop = 1000 ]])

function GrepWord(query)
  exec(string.format('Grepper -query "%s"', fn.escape(query, '"')), false)
end

function GrepCurrentWord()
  cmd("Grepper -cword")
  fn.histdel("@", -1)
end

function SearchFilesRegex()
  fn.inputsave()
  local query = fn.input("Search in files: ")
  fn.inputrestore()
  if not (query == "") then
    return GrepWord(query)
  end
end

function GrepVisual()
  local selection = get_visual_selection(0)
  if #selection == 0 then
    print("empty selection")
    return
  end
  GrepWord(table.concat(get_visual_selection(0), ""))
end

cmd("command! GrepWord lua GrepCurrentWord()")
cmd("command! SearchInFiles lua SearchFilesRegex()")
cmd("command! GrepVisual lua GrepVisual()")
