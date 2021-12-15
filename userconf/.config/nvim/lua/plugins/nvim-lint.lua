cmd = vim.cmd
bo = vim.bo

local lint = require("lint")
local linters = require("config").linters

lint.linters_by_ft = linters

function Lint()
  cmd("silent write")
  lint.try_lint()
  local filetype = bo.filetype
  local ft_linters = linters[filetype]
  if ft_linters then
    print("try lint with [" .. table.concat(ft_linters, ", ") .. "] ...")
  else
    print("no linters for " .. filetype)
  end
end

cmd("command! Lint lua Lint()")
