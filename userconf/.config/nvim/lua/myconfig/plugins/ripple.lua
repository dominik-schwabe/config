local api = vim.api
local fn = vim.fn
local g = vim.g
local bo = vim.bo

g.ripple_enable_mappings = 0
g.ripple_term_name = "term://ripple"
g.ripple_repls = {
  javascript = "node",
  r = "radian",
}

local get_visual_selection = require("myconfig.utils").get_visual_selection

local function replace_tab(str)
  return str:gsub("\t", string.rep(" ", bo.tabstop))
end

local function num_leading_spaces(str)
  local first_char = str:find("[^ ]")
  return first_char and first_char - 1 or #str
end

local function is_whitespace(str)
  return str:match([[^%s*$]])
end

local function filter(list, cb)
  local filtered = {}
  for _, el in ipairs(list) do
    if cb(el) then
      filtered[#filtered + 1] = el
    end
  end
  return filtered
end

local function transform(list, cb)
  local mapped = {}
  for _, el in ipairs(list) do
    mapped[#mapped + 1] = cb(el)
  end
  return mapped
end

local function remove_empty_lines(lines)
  return filter(lines, function(line)
    return not is_whitespace(line)
  end)
end

local function fix_indent(lines)
  local min_indent = nil
  for _, el in ipairs(lines) do
    local num_space = num_leading_spaces(el)
    min_indent = min_indent and math.min(min_indent, num_space) or num_space
  end
  return transform(lines, function(line)
    return line:sub(min_indent)
  end)
end

local function send_lines(lines)
  if #lines == 0 then
    return
  end
  lines = transform(lines, replace_tab)
  lines = remove_empty_lines(lines)
  lines = fix_indent(lines)
  if #lines ~= 0 then
    local num_last_line_string = num_leading_spaces(lines[#lines])
    lines = table.concat(lines, "\n")
    if num_last_line_string ~= 0 then
      lines = lines .. "\n"
    end
    fn["ripple#command"]("", "", lines)
  end
end

local function send_paragraph()
  local i, c = unpack(api.nvim_win_get_cursor(0))
  local max = api.nvim_buf_line_count(0)
  local j = i
  local res = i
  local line = replace_tab(fn.getline(i))
  local indentation_of_first_line = num_leading_spaces(line)
  local last_was_empty = false
  while j < max do
    j = j + 1
    line = fn.getline(j)
    if is_whitespace(line) then
      last_was_empty = true
    else
      line = replace_tab(line)
      if last_was_empty and num_leading_spaces(line) <= indentation_of_first_line then
        break
      end
      res = j
      last_was_empty = false
    end
  end
  send_lines(fn.getline(i, res))
  fn.cursor(j < max and j or max, c + 1)
end

local function send_selection()
  send_lines(get_visual_selection(0))
end

local function send_buffer()
  send_lines(fn.getline(0, "$"))
end

local function send_line()
  local l, c = unpack(api.nvim_win_get_cursor(0))
  local line = fn.getline(l)
  if not is_whitespace(line) then
    fn["ripple#command"]("", "", line)
  end
  pcall(api.nvim_win_set_cursor, 0, { l + 1, c })
end

local function repl_open()
  vim.fn["ripple#open_repl"](0)
end

vim.api.nvim_create_user_command("ReplSendLine", send_line, {})
vim.api.nvim_create_user_command("ReplSendBuffer", send_buffer, {})
vim.api.nvim_create_user_command("ReplSendSelection", send_selection, {})
vim.api.nvim_create_user_command("ReplSendParagraph", send_paragraph, {})
vim.api.nvim_create_user_command("ReplOpen", repl_open, {})
