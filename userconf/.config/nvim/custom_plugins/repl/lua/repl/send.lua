local api = vim.api

local window = require("repl.window");
local get = require("repl.get")

local M = {}

local function set_cursor(winnr, line, col)
  api.nvim_win_set_cursor(winnr, { math.min(line, api.nvim_buf_line_count(api.nvim_win_get_buf(winnr))), col })
end

function M.paragraph(ft)
  local win = vim.api.nvim_get_current_win()
  local l, c = unpack(api.nvim_win_get_cursor(win))
  local lines = get.paragraph()
  window.send(ft, lines)
  set_cursor(win, l + #lines, c)
end

function M.line(ft)
  local win = vim.api.nvim_get_current_win()
  local l, _ = unpack(api.nvim_win_get_cursor(win))
  window.send(ft, { get.line(l) })
end

function M.line_next(ft)
  local win = vim.api.nvim_get_current_win()
  local l, c = unpack(api.nvim_win_get_cursor(win))
  window.send(ft, { get.line(l) })
  set_cursor(win, l + 1, c)
end

function M.visual(ft)
  window.send(ft, get.visual())
end

function M.motion(ft)
  local extra = "''"
  if ft ~= nil then
    extra = "'ft_" .. ft .. "'"
  end
  vim.opt.operatorfunc = "v:lua.require'repl.motion'.build_operatorfunc" .. extra
  vim.api.nvim_feedkeys("g@", "ni", false)
end

function M.newline(ft)
  window.send(ft, nil)
end

function M.buffer(ft)
  window.send(ft, get.buffer())
end

return M
