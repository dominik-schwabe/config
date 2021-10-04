local api = vim.api
local fn = vim.fn
local g = vim.g
local v = vim.v
local bo = vim.bo
local map = api.nvim_set_keymap

local def_opt = {noremap = true, silent = true}

g.ripple_enable_mappings = 0
g.ripple_term_name = "term:// ripple"
g.ripple_repls = {
  javascript= "node",
}

local function replace_tab(str)
  return str:gsub("\t", string.rep(" ", bo.tabstop))
end

local function num_leading_spaces(str)
  local first_char = str:find("[^ ]")
  return first_char and first_char - 1 or #str
end

local function is_whitespace(str)
  return str:match([[^\s*$]])
end

local function filter(list, cb)
  local filtered = {}
  for _, el in ipairs(list) do
    if cb(el) then
      filtered[#filtered+1] = el
    end
  end
  return filtered
end

local function transform(list, cb)
  local mapped = {}
  for _, el in ipairs(list) do
    mapped[#mapped+1] = cb(el)
  end
  return mapped
end

local function remove_empty_lines(lines)
  return filter(lines, function(line) return not is_whitespace(line) end)
end

local function fix_indent(lines)
  local min_indent = nil
  for _, el in ipairs(lines) do
    local num_space = num_leading_spaces(el)
    min_indent = min_indent and math.min(min_indent, num_space) or num_space
  end
  return transform(lines, function(line) return line:sub(min_indent) end)
end

function SendLines(lines)
  if #lines == 0 then return end
  lines = transform(lines, replace_tab)
  lines = remove_empty_lines(lines)
  lines = fix_indent(lines)
  if #lines ~= 0 then
    local num_last_line_string = num_leading_spaces(lines[#lines])
    lines = table.concat(lines, "\n")
    if num_last_line_string ~= 0 then lines = lines .. "\n" end
    fn["ripple#command"]("", "", lines)
  end
end

function SendParagraph()
  local i = api.nvim_win_get_cursor(0)[1]
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
  SendLines(fn.getline(i, res))
  fn.cursor(j < max and j or max, i)
end

function SendSelection()
  local lines = remove_empty_lines(fn.getline("'<", "'>"))
  lines = fix_indent(lines)
  if #lines ~= 0 then
    local num_last_line_string = num_leading_spaces(lines[#lines])
    lines = table.concat(lines, "\n")
    if num_last_line_string ~= 0 then lines = lines .. "\n" end
    fn["ripple#command"]("", "", lines)
  end
  fn["repeat#set"](":lua SendSelection()\n", v.count)
end


function SendBuffer()
  SendLines(fn.getline(0, "$"))
  fn["repeat#set"](":lua SendBuffer()\n", v.count)
end

function SendLine()
  local l, c = unpack(api.nvim_win_get_cursor(0))
  local line = fn.getline(l)
  if not is_whitespace(line) then fn["ripple#command"]("", "", line) end
  pcall(api.nvim_win_set_cursor, 0, {l+1, c})
  fn["repeat#set"](":lua SendLine()\n", v.count)
end

map("n", "<space><space>", "<CMD>lua SendLine()<CR>", {})
map("v", "<C-space>", "<CMD>lua SendSelection()<CR>", def_opt)
map("n", "<C-space>", "<CMD>lua SendParagraph()<CR>", def_opt)
map("n", "<leader><space>", "<CMD>lua SendBuffer()<CR>", def_opt)

map("n", "<F4>", "<cmd>call ripple#open_repl(1)<CR>", def_opt)
