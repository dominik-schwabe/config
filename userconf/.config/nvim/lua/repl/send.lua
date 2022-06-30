local api = vim.api

local window = require("repl.window")
local get = require("repl.get")

local M = {}

local function set_cursor(winnr, line, col)
  api.nvim_win_set_cursor(winnr, { math.min(line, api.nvim_buf_line_count(api.nvim_win_get_buf(winnr))), col })
end

function M.paragraph(ft)
  local winnr = vim.fn.win_getid(api.nvim_win_get_number(0))
  local i, c = unpack(api.nvim_win_get_cursor(winnr))
  local lines = get.paragraph()
  window.send(ft, lines)
  print(i+#lines)
  set_cursor(winnr, i + #lines, c)
end

function M.line(ft)
  local winnr = vim.fn.win_getid(api.nvim_win_get_number(0))
  local l, c = unpack(api.nvim_win_get_cursor(winnr))
  window.send(ft, { get.line(l) })
  set_cursor(winnr, l + 1, c)
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
