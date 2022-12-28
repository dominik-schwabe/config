local api = vim.api

local pp = require("repl.preprocess")
local utils = require("repl.utils")

local M = {}

function M.lines(start_line, num)
  start_line = math.max(0, start_line - 1)
  return api.nvim_buf_get_lines(0, start_line, start_line + num, false)
end

function M.line(number)
  return M.lines(number, 1)[1]
end

function M.visual()
  return utils.get_visual_selection(0)
end

function M.paragraph()
  local i = api.nvim_win_get_cursor(0)[1]
  local j = i
  local line = pp.replace_tab(M.line(i))
  local indentation_of_first_line = pp.num_leading_spaces(line)
  local last_was_empty = false
  while j do
    j = j + 1
    line = M.line(j)
    if line == nil then
      break
    end
    D({last_was_empty, pp.num_leading_spaces(line), indentation_of_first_line, line})
    if pp.is_whitespace(line) then
      last_was_empty = true
    else
      line = pp.replace_tab(line)
      if last_was_empty and pp.num_leading_spaces(line) <= indentation_of_first_line then
        break
      end
      last_was_empty = false
    end
  end
  return M.lines(i, j - i)
end

function M.buffer()
  return api.nvim_buf_get_lines(0, 0, -1, false)
end

return M
