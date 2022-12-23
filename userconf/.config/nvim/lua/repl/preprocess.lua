local bo = vim.bo

local F = require("repl.functional")

local M = {}

M.is_windows = vim.fn.has('win32') == 1

function M.is_whitespace(str)
  return str:match([[^%s*$]])
end

function M.add_windows_linefeed(lines)
  return F.map(lines, function(str) return str .. "\13" end)
end

function M.num_leading_spaces(str)
  local first_char = str:find("[^ ]")
  return first_char and first_char or #str
end

function M.replace_tab(str)
  return str:gsub("\t", string.rep(" ", bo.tabstop))
end

function M.replace_tabs(lines)
  return F.map(lines, M.replace_tab)
end

function M.remove_empty_lines(lines)
  return F.filter(lines, function(str)
    return not M.is_whitespace(str)
  end)
end

function M.fix_indent(lines)
  local min_indent = F.min(F.map(M.remove_empty_lines(lines), M.num_leading_spaces))
  return F.map(lines, function(line)
    return line:sub(min_indent)
  end)
end

function M.preprocess(lines)
  lines = M.replace_tabs(lines)
  lines = M.remove_empty_lines(lines)
  if #lines > 1 then
    lines = M.fix_indent(lines)
  end
  if M.is_windows then
    lines = M.add_windows_linefeed(lines)
  end
  return lines
end

return M
