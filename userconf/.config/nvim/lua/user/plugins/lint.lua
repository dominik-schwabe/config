local F = require("user.functional")

local lint = require("lint")
local linters = require("user.config").linters

local lint_programs = F.unique(F.concat(unpack(F.values(linters))))
lint.linters_by_ft = linters
lint.linters.chktex.ignore_exitcode = true

local function lint_buffer()
  vim.cmd("silent write")
  lint.try_lint()
  local filetype = vim.bo.filetype
  local ft_linters = linters[filetype]
  if ft_linters then
    vim.notify("try lint with [" .. table.concat(ft_linters, ", ") .. "] ...")
  else
    vim.notify("no linters for " .. filetype)
  end
end

local function hide_lint()
  local namespaces = vim.api.nvim_get_namespaces()
  local lint_namespaces = F.map(
    F.filter(F.entries(namespaces), function(entry)
      return F.contains(lint_programs, entry[1])
    end),
    function(entry)
      return entry[2]
    end
  )
  F.foreach(lint_namespaces, vim.diagnostic.reset)
end

vim.api.nvim_create_user_command("Lint", lint_buffer, {})

vim.keymap.set("n", "<space>cl", lint_buffer, { desc = "lint buffer" })
vim.keymap.set("n", "dal", hide_lint, { desc = "hide linter diagnostics" })
