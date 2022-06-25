local api = vim.api

local window = require("repl.window")
local get = require("repl.get")
local utils = require("repl.utils")

local M = {}

function M.paragraph(ft)
  local i, c = unpack(api.nvim_win_get_cursor(0))
  local lines = get.paragraph()
  window.send(ft, lines)
  pcall(api.nvim_win_set_cursor, 0, { i + #lines, c + 1 })
end

function M.line(ft)
  local l, c = unpack(api.nvim_win_get_cursor(0))
  window.send(ft, { get.line(l) })
  pcall(api.nvim_win_set_cursor, 0, { l + 1, c })
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
