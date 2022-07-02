local api = vim.api
local fn = vim.fn

local F = require("user.functional")

local function resize_height(val)
  api.nvim_win_set_height(0, api.nvim_win_get_height(0) + val)
end
local function resize_width(val)
  api.nvim_win_set_width(0, api.nvim_win_get_width(0) + val)
end

local function smart_resize(dir)
  local hwin = fn.winnr("h")
  local kwin = fn.winnr("k")
  local lwin = fn.winnr("l")
  local jwin = fn.winnr("j")

  if hwin ~= lwin then
    if dir == 0 then
      resize_width(5)
    else
      resize_width(-5)
    end
  elseif kwin ~= jwin then
    if dir == 0 then
      resize_height(1)
    else
      resize_height(-1)
    end
  end
end

vim.keymap.set({ "n", "x" }, "+", F.f(smart_resize, 0))
vim.keymap.set({ "n", "x" }, "-", F.f(smart_resize, 1))
