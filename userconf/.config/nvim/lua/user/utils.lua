local api = vim.api
local fn = vim.fn
local o = vim.o

local F = require("user.functional")

local M = {}

function M.reverse_replace_termcodes(str)
  str = str:gsub("\27", "<ESC>")
  str = str:gsub("\r\n", "<CR>")
  str = str:gsub("\r", "<CR>")
  return str
end

function M.replace_termcodes(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

function M.feedkeys(key, mode, need_escape)
  if mode == nil then
    mode = ""
  end
  need_escape = need_escape == nil or need_escape
  if need_escape then
    key = M.replace_termcodes(key)
  end
  api.nvim_feedkeys(key, mode, need_escape)
end

local esc = M.replace_termcodes("<Esc>")
local ctrl_v = M.replace_termcodes("<c-v>")

function M.get_visual_selection(buffer)
  local to_end = fn.winsaveview().curswant == 2147483647
  M.feedkeys(esc, "nx", false)
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
  local line_start, column_start = unpack(api.nvim_buf_get_mark(0, "["))
  local line_end, column_end = unpack(api.nvim_buf_get_mark(0, "]"))

  local lines = api.nvim_buf_get_lines(0, line_start - 1, line_end, 0)

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

function M.buf_options_set(bufnr, options)
  return F.all(options, function(option)
    return api.nvim_buf_get_option(bufnr, option)
  end)
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
  local this_folder = fn.fnamemodify(this_file, ":h")
  local this_file_end = fn.fnamemodify(this_file, ":t")
  local files = fn.readdir(this_folder)
  for _, file in ipairs(files) do
    if file ~= this_file_end then
      require(module_path .. "." .. fn.fnamemodify(file, ":r"))
    end
  end
end

function M.esc_wrap(func)
  return function()
    M.feedkeys(esc, "n", false)
    func()
  end
end

function M.exists(path)
  return fn.empty(fn.glob(path)) == 0
end

function M.mru_buffers()
  local buffers = api.nvim_exec(":ls t", true)
  buffers = vim.split(buffers, "\n")
  buffers = F.map(buffers, function(e)
    return tonumber(e:match("^%s*(%d+)"))
  end)
  return buffers
end

function M.last_regular_buffer()
  local buffers = M.mru_buffers()
  return F.find(buffers, function(bufnr)
    local buftype = api.nvim_buf_get_option(bufnr, "buftype")
    return not vim.tbl_contains({ "terminal", "quickfix", "nofile" }, buftype)
      and M.buf_options_set(bufnr, { "modifiable" })
      and M.exists(api.nvim_buf_get_name(bufnr))
  end)
end

function M.clip(value, lower, upper)
  return math.min(math.max(value, lower), upper)
end

local function num_leading_spaces(str)
  local first_char = str:find("[^ ]")
  return first_char and first_char or #str
end

function M.replace_tab(str)
  return str:gsub("\t", string.rep(" ", vim.bo.tabstop))
end

function M.replace_tabs(lines)
  return F.map(lines, M.replace_tab)
end

local function is_whitespace(str)
  return str:match([[^%s*$]])
end

function M.remove_empty_lines(lines)
  return F.filter(lines, function(str)
    return not is_whitespace(str)
  end)
end

function M.fix_indent(lines)
  local spaces = F.map(M.remove_empty_lines(lines), num_leading_spaces)
  local min_indent = #spaces > 0 and F.min(spaces) or 0
  return F.map(lines, function(line)
    return line:sub(min_indent)
  end)
end

function M.lines_are_same(lines1, lines2)
  if #lines1 ~= #lines2 then
    return false
  end
  for i, v in ipairs(lines1) do
    if v ~= lines2[i] then
      return false
    end
  end
  return true
end

function M.remove_leading_space(str)
  return str:gsub("^[\t\n ]+", "")
end

function M.call_deferred(callback)
  vim.loop.new_timer():start(0, 0, vim.schedule_wrap(callback))
end

function M.deferred_callback(callback)
  return function()
    M.call_deferred(callback)
  end
end

function M.close_win(win)
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
end

return M
