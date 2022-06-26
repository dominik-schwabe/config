local api = vim.api

local window = require("repl.window")
local get = require("repl.get")
local utils = require("repl.utils")

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
  vim.opt.operatorfunc = "v:lua.require'repl.utils'.persist_motion"
  vim.api.nvim_feedkeys("g@", "ni", false)
  window.send(ft, utils.last_motion)
end

function M.buffer(ft)
  window.send(ft, get.buffer())
end

return M
