local api = vim.api
local fn = vim.fn
local o = vim.o

M = {}

local function replace_termcodes(str)
  return vim.api.nvim_replace_termcodes(str, false, true, true)
end

local esc = replace_termcodes("<Esc>")
local ctrl_v = replace_termcodes("<c-v>")

function M.get_visual_selection(buffer)
  local to_end = fn.winsaveview().curswant == 2147483647
  api.nvim_feedkeys(esc, "nx", false)
  local line_start, column_start = unpack(api.nvim_buf_get_mark(buffer, "<"))
  local line_end, column_end = unpack(api.nvim_buf_get_mark(buffer, ">"))
  local lines = api.nvim_buf_get_lines(buffer, line_start - 1, line_end, false)
  column_start = column_start + 1
  if o.selection == "inclusive" then
    column_end = column_end + 1
  end
  if fn.visualmode() == ctrl_v then
    if column_start > column_end then
      column_start, column_end = column_end, column_start
    end
    for i = 1, #lines do
      if to_end then
        lines[i] = lines[i]:sub(column_start)
      else
        lines[i] = lines[i]:sub(column_start, column_end)
      end
    end
  else
    if column_end > #lines[#lines] then
      column_end = #lines[#lines]
    end
    lines[#lines] = lines[#lines]:sub(0, column_end)
    lines[1] = lines[1]:sub(column_start)
  end
  return lines
end

function M.get_motion(motion_type)
  local line_start, column_start = unpack(vim.api.nvim_buf_get_mark(0, "["))
  local line_end, column_end = unpack(vim.api.nvim_buf_get_mark(0, "]"))

  local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, 0)

  if motion_type ~= "line" then
    lines[#lines] = lines[#lines]:sub(0, column_end + 1)
    lines[1] = lines[1]:sub(column_start + 1)
  end

  return lines
end

function M.path_exists(path)
  return vim.fn.empty(vim.fn.glob(path)) == 0
end

function M.extend(tbl)
  local new_tbl = {}
  for _, e in pairs(tbl) do
    if type(e) == "table" then
      for _, l in pairs(e) do
        new_tbl[#new_tbl + 1] = l
      end
    else
      new_tbl[#new_tbl + 1] = e
    end
  end
  return new_tbl
end

function M.debug(...)
  local tbl = { ... }
  local new_tbl = {}
  for _, e in pairs(tbl) do
    new_tbl[#new_tbl + 1] = vim.inspect(e)
  end
  if #new_tbl ~= 0 then
    print(unpack(new_tbl))
  else
    print("--- empty ---")
  end
end

return M
