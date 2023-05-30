local F = require("user.functional")

local function trim_whitespace()
  local buffer = vim.api.nvim_buf_get_number(0)
  if not vim.api.nvim_buf_get_option(buffer, "modifiable") then
    vim.notify("not modifiable")
    return
  end
  local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
  lines = F.map(lines, function(line)
    return line:gsub("%s+$", "")
  end)
  local end_index = #lines
  while end_index > 0 and lines[end_index] == "" do
    lines[end_index] = nil
    end_index = end_index - 1
  end
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
end

vim.api.nvim_create_user_command("TrimWhitespace", trim_whitespace, {})
vim.keymap.set({ "n", "x" }, "<space>.", trim_whitespace, { desc = "trim whitespace and last empty lines" })
