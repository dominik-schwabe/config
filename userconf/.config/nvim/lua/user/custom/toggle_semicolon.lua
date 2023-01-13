local api = vim.api

local F = require("user.functional")

local function toggle_end_char(char)
  local row = api.nvim_win_get_cursor(0)[1]
  local curr_line = api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  local next_line
  if curr_line:sub(#curr_line, #curr_line) == char then
    next_line = curr_line:sub(0, #curr_line - 1)
  else
    next_line = curr_line .. char
  end
  api.nvim_buf_set_text(0, row - 1, 0, row - 1, #curr_line, { next_line })
end

vim.keymap.set("n", ",", F.f(toggle_end_char, ","), { desc = "toggle ',' at end of line" })
vim.keymap.set("n", ";", F.f(toggle_end_char, ";"), { desc = "toggle ';' at end of line" })
