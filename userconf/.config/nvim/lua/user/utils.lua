local F = require("user.functional")
local config = require("user.config")

local M = {}

function M.reverse_replace_termcodes(str)
  str = str:gsub("\27", "<ESC>")
  str = str:gsub("\r\n", "<CR>")
  str = str:gsub("\r", "<CR>")
  return str
end

function M.replace_termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function M.feedkeys(key, mode, need_escape)
  if mode == nil then
    mode = ""
  end
  need_escape = need_escape == nil or need_escape
  if need_escape then
    key = M.replace_termcodes(key)
  end
  vim.api.nvim_feedkeys(key, mode, need_escape)
end

local esc = M.replace_termcodes("<Esc>")
local ctrl_v = M.replace_termcodes("<c-v>")

function M.get_visual_selection(buffer)
  local to_end = vim.fn.winsaveview().curswant == 2147483647
  M.feedkeys(esc, "nx", false)
  local line_start, column_start = unpack(vim.api.nvim_buf_get_mark(buffer, "<"))
  local line_end, column_end = unpack(vim.api.nvim_buf_get_mark(buffer, ">"))
  local lines = vim.api.nvim_buf_get_lines(buffer, line_start - 1, line_end, false)
  column_start = column_start + 1
  if vim.o.selection == "inclusive" then
    column_end = column_end + 1
  end
  if vim.fn.visualmode() == ctrl_v then
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

function M.buf_options_set(bufnr, options)
  return F.all(options, function(option)
    return vim.api.nvim_buf_get_option(bufnr, option)
  end)
end

function M.tbl_merge(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k]) == "table") then
      if vim.tbl_islist(t1[k]) and vim.tbl_islist(v) then
        t1[k] = F.concat(t1[k], v)
      else
        M.tbl_merge(t1[k], v)
      end
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
    M.feedkeys(esc, "n", false)
    func()
  end
end

function M.exists(path)
  return vim.fn.empty(vim.fn.glob(path)) == 0
end

function M.mru_buffers()
  local buffers = vim.api.nvim_exec(":ls t", true)
  buffers = vim.split(buffers, "\n")
  buffers = F.map(buffers, function(e)
    return tonumber(e:match("^%s*(%d+)"))
  end)
  return buffers
end

function M.last_regular_buffer()
  local buffers = M.mru_buffers()
  return F.find(buffers, function(bufnr)
    local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
    return not F.contains({ "terminal", "quickfix", "nofile" }, buftype)
      and M.buf_options_set(bufnr, { "modifiable" })
      and M.exists(vim.api.nvim_buf_get_name(bufnr))
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

function M.close_win(win)
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
end

function M.input(prompt, callback)
  vim.ui.input(prompt, function(arg)
    if arg ~= nil then
      callback(arg)
    end
  end)
end

function M.desc(opts, description)
  opts = vim.deepcopy(opts)
  opts.desc = description
  return opts
end

function M.buffer_size(buf)
  return math.max(vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) - 1, 0)
end

function M.is_big_buffer(buf, max_size)
  max_size = max_size or config.max_buffer_size
  return M.buffer_size(buf) > max_size
end

function M.is_big_buffer_whitelisted(buf, max_size, whitelist)
  whitelist = whitelist or config.big_files_whitelist
  return M.is_big_buffer(buf, max_size) and not vim.tbl_contains(config.big_files_whitelist, vim.bo[buf].filetype)
end

function M.convert(b)
  local num_digits = math.max(math.floor(math.log10(b)), 0)
  local lower_power = num_digits - num_digits % 3
  local order = lower_power / 3
  local unit
  local color
  if order == 0 then
    unit = "B"
    color = "White"
  elseif order <= 1 then
    unit = "K"
    color = "Aqua"
  elseif order == 2 then
    unit = "M"
    color = "Yellow"
  elseif order == 3 then
    unit = "G"
    color = "Pink"
  elseif order == 4 then
    unit = "T"
    color = "Pink"
  elseif order == 5 then
    unit = "P"
    color = "Pink"
  elseif order == 6 then
    unit = "E"
    color = "Pink"
  elseif order == 7 then
    unit = "Z"
    color = "Pink"
  elseif order == 8 then
    unit = "Y"
    color = "Pink"
  end
  local num = b / math.pow(1000, order)
  return {
    value = num,
    unit = unit,
    color = color,
  }
end

function M.add_slash(path)
  if path:sub(-1) ~= "/" then
    path = path .. "/"
  end
  return path
end

function M.has_prefix(str, prefix)
  return str:sub(1, #prefix) == prefix
end

function M.has_suffix(str, suffix)
  return str:sub(-#suffix) == suffix
end

function M.remove_prefix(path, prefix)
  if M.has_prefix(path, prefix) then
    return prefix, path:sub(#prefix + 1)
  end
  return nil, path
end

function M.remove_suffix(path, suffix)
  if M.has_suffix(path, suffix) then
    return path:sub(1, -#suffix - 1), suffix
  end
  return path, nil
end

function M.is_floating(win)
  return vim.api.nvim_win_get_config(win).zindex ~= nil
end

function M.simplify_path(path)
  path = vim.fn.simplify(path)
  path = path:gsub("/+", "/")
  return path
end

function M.split_cwd_path(path)
  local cwd = M.add_slash(vim.loop.cwd())
  if path:sub(0, 1) ~= "/" then
    path = cwd .. "/" .. path
  end
  path = M.simplify_path(path)
  local prefix, suffix = M.remove_prefix(path, cwd)
  if prefix then
    local home, rest_prefix = M.remove_prefix(prefix, M.add_slash(vim.env.HOME))
    if home then
      prefix = "~/" .. rest_prefix
    end
  end
  return prefix, suffix
end

function M.quickfix(lines, title)
  if type(lines[1]) == "table" then
    vim.fn.setqflist(lines, " ")
    vim.fn.setqflist({}, "a", { title = title })
  else
    vim.fn.setqflist({}, "r", { title = title, lines = lines })
  end
  vim.api.nvim_command("botright copen")
end

return M
