local F = require("user.functional")
local U = require("user.utils")

local function show_diagnostics(only_buffer)
  local diagnostics = vim.diagnostic.get()
  if only_buffer then
    local bufnr = U.last_regular_buffer()
    diagnostics = F.filter(diagnostics, function(e)
      return e.bufnr == bufnr
    end)
  end
  diagnostics = vim.diagnostic.toqflist(diagnostics)
  U.quickfix(diagnostics, "Diagnostics")
end

vim.keymap.set("n", "<space>d", function()
  show_diagnostics(true)
end, { desc = "show buffer diagnostics in quickfix" })
vim.keymap.set("n", "<space>w", function()
  show_diagnostics(false)
end, { desc = "show workspace diagnostics in quickfix" })
