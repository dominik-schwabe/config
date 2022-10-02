local api = vim.api
local fn = vim.fn
local o = vim.o

local M = {}

function M.replace_termcodes(str)
  return vim.api.nvim_replace_termcodes(str, false, true, true)
end

local esc = M.replace_termcodes("<Esc>")
local ctrl_v = M.replace_termcodes("<c-v>")

function M.get_visual_selection(buffer)
  local to_end = fn.winsaveview().curswant == 2147483647
  api.nvim_feedkeys(M.replace_termcodes("<Esc>"), "nx", false)
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

    local end_pos = to_end and column_end or nil
    for i = 1, #lines do
      lines[i] = lines[i]:sub(column_start, end_pos)
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

function M.get_shifts(num)
  local text
  if vim.bo.expandtab then
    text = string.rep(" ", vim.bo.tabstop)
  else
    text = "\t"
  end
  text = string.rep(text, math.floor(num * vim.bo.shiftwidth / vim.bo.tabstop))
  return text
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

function M.load_neighbor_modules(this_file, module_path)
  local this_folder = vim.fn.fnamemodify(this_file, ":h")
  local this_file_end = vim.fn.fnamemodify(this_file, ":t")
  local files = vim.fn.readdir(this_folder)
  for _, file in ipairs(files) do
    if file ~= this_file_end then
      require(module_path .. "." .. vim.fn.fnamemodify(file, ":r"))
    end
  end
end

function M.esc_wrap(func)
  return function()
    -- vim.cmd("stopinsert")
    -- api.nvim_feedkeys(esc, "nx", false)
    api.nvim_feedkeys(esc, "", false)
    func()
  end
end

function M.exists(path)
  return vim.fn.empty(vim.fn.glob(path)) == 0
end

function M.concat(...)
  local new_table = {}
  for _, t in ipairs({ ... }) do
    for _, v in ipairs(t) do
      new_table[#new_table + 1] = v
    end
  end
  return new_table
end

return M
