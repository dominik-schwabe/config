local fn = vim.fn
local o = vim.o
local api = vim.api

M = {}

function M.get_visual_selection(buffer)
  local line_start, column_start = unpack(api.nvim_buf_get_mark(buffer, "<"))
  local line_end, column_end = unpack(api.nvim_buf_get_mark(buffer, ">"))
  local lines = api.nvim_buf_get_lines(buffer, line_start - 1, line_end, false)
  column_end = column_end - (o.selection == "inclusive" and 0 or 1)
  lines[#lines] = lines[#lines]:sub(0, column_end + 1)
  lines[1] = lines[1]:sub(column_start + 1)
  return lines
end

return M
