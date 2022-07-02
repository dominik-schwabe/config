local api = vim.api
local fn = vim.fn
local bo = vim.bo

local iron = require("iron.core")
local get_visual_selection = require("user.utils").get_visual_selection

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
  lines = transform(lines, replace_tab)
  lines = remove_empty_lines(lines)
  lines = fix_indent(lines)
  if #lines ~= 0 then
    if #lines == 1 and (bo.ft == "python" or bo.ft == "r") then
      iron.send(bo.ft, { "\27[200~" .. lines[1] .. "\27[201~" })
    else
      iron.send(bo.ft, lines)
    end
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
  local lines = remove_empty_lines(get_visual_selection(0))
  lines = fix_indent(lines)
  send_lines(lines)
end

local function send_buffer()
  send_lines(fn.getline(0, "$"))
end

local function send_line()
  local l, c = unpack(api.nvim_win_get_cursor(0))
  local line = fn.getline(l)
  if not is_whitespace(line) then
    send_lines({ line })
  end
  pcall(api.nvim_win_set_cursor, 0, { l + 1, c })
end

local function repl_open()
  iron.repl_for(bo.ft)
end

local function repl_open_cmd(buff, _)
  api.nvim_command("botright vertical split")
  api.nvim_set_current_buf(buff)

  local winnr = fn.bufwinnr(buff)
  local winid = fn.win_getid(winnr)
  api.nvim_buf_set_name(buff, "term://ironrepl")
  local timer = vim.loop.new_timer()
  timer:start(
    0,
    0,
    vim.schedule_wrap(function()
      api.nvim_buf_set_name(buff, "term://ironrepl")
    end)
  )
  return winid
end

local extend = require("iron.util.tables").extend

local function format(open, close, cr)
  return function(lines)
    if #lines == 1 then
      return { lines[1] .. cr }
    else
      local new = { open .. lines[1] }
      for line = 2, #lines do
        table.insert(new, lines[line])
      end
      return extend(new, close)
    end
  end
end

vim.api.nvim_create_user_command("ReplSendLine", send_line, {})
vim.api.nvim_create_user_command("ReplSendBuffer", send_buffer, {})
vim.api.nvim_create_user_command("ReplSendSelection", send_selection, {})
vim.api.nvim_create_user_command("ReplSendParagraph", send_paragraph, {})
vim.api.nvim_create_user_command("ReplOpen", repl_open, {})

iron.setup({
  config = {
    highlight_last = "",
    preferred = require("user.config").repls,
    visibility = require("iron.visibility").toggle,
    repl_open_cmd = repl_open_cmd,
    close_window_on_exit = true,
    scope = require("iron.scope").singleton,
    should_map_plug = false,
    scratch_repl = true,
    buflisted = false,
    repl_definition = {
      r = {
        R = {
          command = { "R" },
          format = format("\27[200~", "\27[201~\r", "\r"),
        },
        radian = {
          command = { "radian" },
          format = format("\27[200~", "\27[201~", "\r"),
        },
      },
    },
  },
})

vim.keymap.set("", "<F11>", send_paragraph)
vim.keymap.set("v", "<space>v", send_selection)
