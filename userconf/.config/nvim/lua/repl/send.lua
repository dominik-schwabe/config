local api = vim.api

local window = require("repl.window")
local get = require("repl.get")
local motion = require("repl.motion")

local M = {}

local function set_cursor(line, col)
  api.nvim_win_set_cursor(0, { math.min(line, api.nvim_buf_line_count(0)), col })
end

function M.paragraph(ft)
  local i, c = unpack(api.nvim_win_get_cursor(0))
  local lines = get.paragraph()
  window.send(ft, lines)
  set_cursor(i + #lines, c)
end

function M.line(ft)
  local l, c = unpack(api.nvim_win_get_cursor(0))
  window.send(ft, { get.line(l) })
  set_cursor(l + 1, c)
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
