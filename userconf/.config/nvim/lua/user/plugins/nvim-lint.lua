local cmd = vim.cmd
local bo = vim.bo

local lint = require("lint")
local linters = require("user.config").linters

lint.linters_by_ft = linters

local function lint_buffer()
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

vim.api.nvim_create_user_command("Lint", lint_buffer, {})

vim.keymap.set("n", "<space>z", lint_buffer)
