local F = require("user.functional")

local function toggle_end_char(char)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local curr_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  local next_line
  if curr_line:sub(#curr_line, #curr_line) == char then
    next_line = curr_line:sub(0, #curr_line - 1)
  else
    next_line = curr_line .. char
  end
  vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, #curr_line, { next_line })
end

local toggle_end_char_cb = F.f(toggle_end_char)

vim.keymap.set("n", ",", toggle_end_char_cb(","), { desc = "toggle ',' at end of line" })
vim.keymap.set("n", ";", toggle_end_char_cb(";"), { desc = "toggle ';' at end of line" })
