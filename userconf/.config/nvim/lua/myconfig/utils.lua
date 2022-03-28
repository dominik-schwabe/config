local fn = vim.fn
local o = vim.o
local api = vim.api

local M = {}

function M.get_visual_selection(buffer)
  local line_start, column_start = unpack(api.nvim_buf_get_mark(buffer, "<"))
  local line_end, column_end = unpack(api.nvim_buf_get_mark(buffer, ">"))
  local lines = api.nvim_buf_get_lines(buffer, line_start - 1, line_end, false)
  column_start = column_start + 1
  if o.selection == "inclusive" and column_end < 0x7FFFFFFF then
    column_end = column_end + 1
  end
  lines[#lines] = lines[#lines]:sub(0, column_end)
  lines[1] = lines[1]:sub(column_start)
  return lines
end

function M.tbl_merge(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      M.tbl_merge(t1[k], t2[k])
    else
      t1[k] = v
    end
  end
  return t1
end

return M
