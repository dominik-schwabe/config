local F = require("user.functional")
local C = require("user.constants")
local config = require("user.config")

local M = {}

---@param str string
---@return string
function M.replace_termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

---@param key string
---@param mode string
---@param need_escape boolean
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

---@param buffer integer
---@return string[]
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

---@param motion_type `line`
---@return string[]
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

---@param num integer
---@return string
function M.get_indents(num)
  local text
  if vim.bo.expandtab then
    text = string.rep(" ", vim.bo.tabstop)
  else
    text = "\t"
  end
  text = string.rep(text, math.floor(num * vim.bo.shiftwidth / vim.bo.tabstop))
  return text
end

---@param t1 table<any, any>
---@param t2 table<any, any>
---@return table<any, any>
function M.tbl_merge(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k]) == "table") then
      if vim.islist(t1[k]) and vim.islist(v) then
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

---@param this_file string
---@param module_path string
function M.load_neighbor_modules(this_file, module_path)
  local this_folder = vim.fn.fnamemodify(this_file, ":h")
  local this_file_end = vim.fn.fnamemodify(this_file, ":t")
  local files = vim.fn.readdir(this_folder)
  for _, file in ipairs(files) do
    if file ~= this_file_end then
      F.load(module_path .. "." .. vim.fn.fnamemodify(file, ":r"), nil, false)
    end
  end
end

---@param path string
---@return boolean
function M.exists(path)
  return path and vim.fn.empty(vim.fn.glob(path)) == 0
end

---@param path string
---@return boolean
function M.isdirectory(path)
  return path and vim.fn.isdirectory(path) == 1
end

function M.list_buffers(opts)
  opts = vim.F.if_nil(opts, {})
  if opts.buftype and type(opts.buftype) == "string" then
    opts.buftype = { opts.buftype }
  end
  local buffers = vim.iter(vim.api.nvim_list_bufs())
  if not opts.unloaded then
    buffers = buffers:filter(vim.api.nvim_buf_is_loaded)
  end
  if not opts.unlisted then
    buffers = buffers:filter(function(buf)
      return vim.fn.buflisted(buf) == 1
    end)
  end
  if opts.buftype then
    buffers = buffers:filter(function(buf)
      return vim.tbl_contains(opts.buftype, vim.bo[buf].buftype)
    end)
  end
  buffers = buffers:totable()
  if opts.mru then
    table.sort(buffers, function(a, b)
      return (vim.b[a].user_last_entry or 0) > (vim.b[b].user_last_entry or 0)
    end)
  end
  return buffers
end

function M.last_regular_buffer()
  local buffers = M.list_buffers({ mru = true, buftype = C.PATH_BUFTYPES })
  return F.find(buffers, function(bufnr)
    return M.exists(vim.api.nvim_buf_get_name(bufnr))
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
  local result, _ = str:gsub("\t", string.rep(" ", vim.bo.tabstop))
  return result
end

function M.replace_tabs(lines)
  return vim.iter(lines):map(M.replace_tab):totable()
end

local function is_whitespace(str)
  return str:match([[^%s*$]])
end

function M.remove_empty_lines(lines)
  return vim
    .iter(lines)
    :filter(function(str)
      return not is_whitespace(str)
    end)
    :totable()
end

function M.fix_indent(lines)
  local spaces = vim.iter(M.remove_empty_lines(lines)):map(num_leading_spaces):totable()
  local min_indent = #spaces > 0 and F.min(spaces) or 0
  return vim
    .iter(lines)
    :map(function(line)
      return line:sub(min_indent)
    end)
    :totable()
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
  local result, _ = str:gsub("^[\t\n ]+", "")
  return result
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

function M.buffer_size(buf)
  return math.max(vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) - 1, 0)
end

function M.is_big_buffer(buf, max_size)
  max_size = max_size or config.max_buffer_size or 4294967296
  return M.buffer_size(buf) > max_size
end

function M.is_big_buffer_or_in_allowlist(buf, max_size, allowlist)
  allowlist = allowlist or config.big_files_allowlist
  return M.is_big_buffer(buf, max_size) and not vim.tbl_contains(allowlist, vim.bo[buf].filetype)
end

function M.is_disable_treesitter(filetype, bufnr)
  filetype = filetype or vim.bo.filetype
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return M.is_big_buffer_or_in_allowlist(bufnr) or vim.tbl_contains(config.treesitter.highlight_disable, filetype)
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
  local result, _ = vim.fn.simplify(path):gsub("/+", "/")
  return result
end

function M.path(components, opts)
  opts = opts or {}
  local is_dir = opts.is_dir
  local path = table.concat(components, "/")
  path = vim.fs.normalize(path)
  path = M.simplify_path(path)
  if is_dir and path:sub(-1) ~= "/" then
    path = path .. "/"
  end
  return path
end

function M.replace_root_path(path, root, replacement)
  local split_root, rest_prefix = M.remove_prefix(path, M.path({ root }, { is_dir = true }))
  if split_root then
    path = replacement .. rest_prefix
  end
  return path
end

function M.buffer_path(buf)
  return M.path({ vim.api.nvim_buf_get_name(buf) })
end

function M.cwd()
  return M.path({ vim.loop.cwd() }, { is_dir = true })
end

function M.split_cwd_path(path)
  local cwd = M.cwd()
  path = M.path({ path })
  if path:sub(0, 1) ~= "/" then
    path = M.path({ cwd, path })
  end
  local prefix, suffix = M.remove_prefix(path, cwd)
  if prefix then
    prefix = M.replace_root_path(prefix, "~/", "~/")
  end
  return prefix, suffix
end

function M.quickfix(lines, title)
  if type(lines[1]) == "table" then
    vim.fn.setqflist(lines, " ")
    vim.fn.setqflist({}, "a", { title = title })
  else
    vim.fn.setqflist({}, " ", { title = title, lines = lines })
  end
  vim.api.nvim_command("botright copen")
end

function M.is_quickfix(win)
  if win == 0 then
    win = vim.api.nvim_get_current_win()
  end
  local wininfo = vim.fn.getwininfo(win)[1]
  return wininfo.quickfix == 1 and wininfo.loclist == 0
end

function M.is_loclist(win)
  if win == 0 then
    win = vim.api.nvim_get_current_win()
  end
  local wininfo = vim.fn.getwininfo(win)[1]
  return wininfo.quickfix == 1 and wininfo.loclist == 1
end

function M.quickfix_title(win)
  if M.is_quickfix(win) then
    return vim.fn.getqflist({ title = 0 }).title
  elseif M.is_loclist(win) then
    return vim.fn.getloclist(0, { title = 0 }).title
  end
end

function M.is_dummy_buffer(buf)
  return vim.b[buf].is_dummy
end

function M.get_dummy_buffer()
  local buf = vim.iter(vim.api.nvim_list_bufs()):filter(M.is_dummy_buffer):next()
  if not buf then
    buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true
    vim.b[buf].is_dummy = true
  end
  return buf
end

function M.list_normal_windows()
  return vim
    .iter(vim.api.nvim_list_wins())
    :filter(function(win)
      return not M.is_floating(win)
    end)
    :totable()
end

function M.is_git_ignored(path)
  if vim.fn.executable("git") then
    local job = require("plenary.job"):new({
      command = "git",
      args = { "check-ignore", path },
      cwd = path,
    })
    job:sync()
    return job.code == 0
  else
    return false
  end
end

return M
