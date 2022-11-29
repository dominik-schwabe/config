local gears = require("gears")
local vars = require("main.vars")
local bindkey = require("util.bindkey")

local f = require("functions")

local mod = { vars.modkey }
local mod_shift = { vars.modkey, "Shift" }
local mod_ctrl = { vars.modkey, "Control" }

return gears.table.join(
  bindkey("client", mod, "f", f.fullscreen, "toggle fullscreen"),
  bindkey("client", mod, "udiaeresis", f.move_to_screen, "move to screen"),
  bindkey("client", mod_shift, "q", f.kill, "close"),
  bindkey("client", mod_shift, "space", f.toggle_float, "toggle floating"),
  bindkey("client", mod_ctrl, "Return", f.getmaster, "move to master"),
  bindkey("layout", mod, "+", f.resize_grow, "increase the size of the master or float-x"),
  bindkey("layout", mod_shift, "+", f.resize_grow_x, "increase the size of the client or float-y"),
  bindkey("layout", mod, "-", f.resize_shrink, "decrease the size of the master or float-x"),
  bindkey("layout", mod_shift, "-", f.resize_shrink_x, "decrease the size of the client or float-y"),
  bindkey("layout", mod, "9", f.client_fix("topleft", 400, 225, true), "topleft 400px * 225px"),
  bindkey("layout", mod, "0", f.client_fix("topright", 400, 225, true), "topright 400px * 225px"),
  bindkey("layout", mod_shift, "comma", f.right_sticky, "align right side"),
  bindkey("layout", mod, ".", f.client_fix("center", 800, 500, false), "center 800 * 500"),
  bindkey("layout", mod_shift, ".", f.client_fix("center", 1200, 675, false), "center 1200px * 675px"),
  bindkey("client", mod, "comma", f.toggle_sticky, "toggle sticky"),
  bindkey("client", mod_shift, "h", f.swap_resize_left, "focus the left client"),
  bindkey("client", mod_shift, "j", f.swap_resize_bottom, "focus the bottom client"),
  bindkey("client", mod_shift, "k", f.swap_resize_top, "focus the top client"),
  bindkey("client", mod_shift, "l", f.swap_resize_right, "focus the right client"),

  -- Resize
  bindkey("client", mod_shift, "Down", f.shrink_top, "shrink the top of the window"),
  bindkey("client", mod_shift, "Up", f.shrink_bottom, "grow the top of the window"),
  bindkey("client", mod_shift, "Left", f.shrink_left, "shrink the right of the window"),
  bindkey("client", mod_shift, "Right", f.shrink_right, "grow the right of the window"),
  bindkey("client", mod, "Down", f.grow_bottom, "shrink the bottom of the window"),
  bindkey("client", mod, "Up", f.grow_top, "grow the bottom of the window"),
  bindkey("client", mod, "Left", f.grow_left, "shrink the left of the window"),
  bindkey("client", mod, "Right", f.grow_right, "grow the left of the window")
)
