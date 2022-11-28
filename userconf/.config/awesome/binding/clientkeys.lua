local awful = require("awful")
local gears = require("gears")
local vars = require("main.vars")
local bindkey = require("util.bindkey")

local f = require("functions")

local mod = { vars.modkey }
local mod_shift = { vars.modkey, "Shift" }
local mod_ctrl = { vars.modkey, "Control" }

return gears.table.join(
  bindkey("client", mod, "f", f.fullscreen, "toggle fullscreen"),
  bindkey("client", mod, "o", f.move_to_screen, "move to screen"),
  bindkey("client", mod, "t", f.ontop, "toggle keep on top"),
  bindkey("client", mod, "n", f.minimize, "minimize"),
  bindkey("client", mod, "m", f.maximize, "(un)maximize"),
  bindkey("client", mod_shift, "m", f.maximized_horizontal, "(un)maximize horizontally"),
  bindkey("client", mod_ctrl, "m", f.maximize_vertical, "(un)maximize vertically"),
  bindkey("client", mod_shift, "q", f.kill, "close"),
  bindkey("client", mod_shift, "space", f.toggle_float, "toggle floating"),
  bindkey("client", mod_ctrl, "Return", f.getmaster, "move to master"),
  bindkey("layout", mod, "+", f.resize_grow, "increase the size of the master or float-x"),
  bindkey("layout", mod_shift, "+", f.resize_grow_x, "increase the size of the client or float-y"),
  bindkey("layout", mod, "-", f.resize_shrink, "decrease the size of the master or float-x"),
  bindkey("layout", mod_shift, "-", f.resize_shrink_x, "decrease the size of the client or float-y"),
  bindkey("layout", mod, "9", f.client_fix("topleft", 400, 225, true), "topleft 400px * 225px"),
  bindkey("layout", mod, "0", f.client_fix("topright", 400, 225, true), "topright 400px * 225px"),
  bindkey("client", mod_shift, "comma", f.toggle_sticky, "toggle sticky"),
  bindkey("client", mod, ".", f.client_fix("center", 800, 500, false), "center 800 * 500"),
  bindkey("client", mod_shift, ".", f.client_fix("center", 1200, 675, false), "center 1200px * 675px"),
  bindkey("layout", mod, "comma", f.right_sticky, "align right side")
)
