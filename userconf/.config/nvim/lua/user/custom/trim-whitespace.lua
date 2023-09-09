local F = require("user.functional")

local function trim_whitespace()
  local buf = vim.api.nvim_get_current_buf()
  local bo = vim.bo[buf]
  if not bo.modifiable then
    vim.notify("not modifiable")
    return
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if bo.filetype ~= "markdown" then
    lines = F.map(lines, function(line)
      return line:gsub("%s+$", "")
    end)
  else
    vim.notify("skip trimming for markdown")
  end
  local end_index = #lines
  while end_index > 0 and lines[end_index] == "" do
    lines[end_index] = nil
    end_index = end_index - 1
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

vim.api.nvim_create_user_command("TrimWhitespace", trim_whitespace, {})
vim.keymap.set({ "n", "x" }, "<space>.", trim_whitespace, { desc = "trim whitespace and last empty lines" })
