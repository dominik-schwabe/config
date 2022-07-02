local api = vim.api

local function trim_whitespace()
  local buffer = api.nvim_buf_get_number(0)
  if not api.nvim_buf_get_option(buffer, "modifiable") then
    print("not modifiable")
    return
  end
  local lines = api.nvim_buf_get_lines(buffer, 0, -1, false)
  for i = 1, #lines do
    lines[i] = lines[i]:gsub("%s+$", "")
  end
  local end_index = #lines
  while end_index > 0 and lines[end_index] == "" do
    lines[end_index] = nil
    end_index = end_index - 1
  end
  api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
end

vim.api.nvim_create_user_command("TrimWhitespace", trim_whitespace, {})
vim.keymap.set({ "n", "x" }, "<space>.", trim_whitespace)
