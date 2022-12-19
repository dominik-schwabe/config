local gears = require("gears")
local vars = require("main.vars")
local bindkey = require("util.bindkey")
local dpi = require("beautiful.xresources").apply_dpi

local f = require("functions")

local mod = { vars.modkey }
local mod_shift = { vars.modkey, "Shift" }
local mod_ctrl = { vars.modkey, "Control" }

local bottom_fixer = f.client_fix("bottom", { width = 1, height = 0.5 })
local top_fixer = f.client_fix("top", { width = 1, height = 0.5 })
local left_fixer = f.client_fix("left", { width = 0.5, height = 1 })
local right_fixer = f.client_fix("right", { width = 0.5, height = 1 })
local center_fixer =
  f.client_fix("centered", { width = 0.85, height = 0.85, max_width = dpi(1200), max_height = dpi(675) })

local top_right_sticky = f.client_fix("top_right", { width = dpi(400), height = dpi(225), sticky = true })
local top_left_sticky = f.client_fix("top_left", { width = dpi(400), height = dpi(225), sticky = true })
local bottom_right_sticky = f.client_fix("bottom_right", { width = dpi(400), height = dpi(225), sticky = true })
local bottom_left_sticky = f.client_fix("bottom_left", { width = dpi(400), height = dpi(225), sticky = true })

return gears.table.join(
  bindkey("client", mod, "f", f.fullscreen, "toggle fullscreen"),
  bindkey("client", mod_shift, "udiaeresis", f.move_to_screen, "move to screen"),
  bindkey("client", mod_shift, "q", f.kill, "close"),
  bindkey("client", mod_shift, "space", f.toggle_float, "toggle floating"),
  bindkey("client", mod_ctrl, "Return", f.getmaster, "move to master"),
  bindkey("layout", mod, "+", f.resize_grow, "increase the size of the master or float-x"),
  bindkey("layout", mod_shift, "+", f.resize_grow_x, "increase the size of the client or float-y"),
  bindkey("layout", mod, "-", f.resize_shrink, "decrease the size of the master or float-x"),
  bindkey("layout", mod_shift, "-", f.resize_shrink_x, "decrease the size of the client or float-y"),
  bindkey("layout", mod, "i", bottom_left_sticky, "bottom left 400px * 225px"),
  bindkey("layout", mod, "o", bottom_right_sticky, "bottom right 400px * 225px"),
  bindkey("layout", mod_shift, "i", top_left_sticky, "top left 400px * 225px"),
  bindkey("layout", mod_shift, "o", top_right_sticky, "top right 400px * 225px"),
  bindkey("layout", mod, ".", center_fixer, "center 1200px * 675px"),
  bindkey("client", mod, "s", f.toggle_sticky, "toggle sticky"),
  bindkey("client", mod_shift, "h", f.swap_resize_left, "focus the left client"),
  bindkey("client", mod_shift, "j", f.swap_resize_bottom, "focus the bottom client"),
  bindkey("client", mod_shift, "k", f.swap_resize_top, "focus the top client"),
  bindkey("client", mod_shift, "l", f.swap_resize_right, "focus the right client"),

  -- Resize
  bindkey("client", mod, "Down", bottom_fixer, "align the window to the bottom"),
  bindkey("client", mod, "Up", top_fixer, "align the window to the top"),
  bindkey("client", mod, "Left", left_fixer, "align the window to the left"),
  bindkey("client", mod, "Right", right_fixer, "align the window to the right"),
  bindkey("client", mod_shift, "Down", f.grow_bottom, "shrink the bottom of the window"),
  bindkey("client", mod_shift, "Up", f.grow_top, "grow the bottom of the window"),
  bindkey("client", mod_shift, "Left", f.grow_left, "shrink the left of the window"),
  bindkey("client", mod_shift, "Right", f.grow_right, "grow the left of the window"),
  bindkey("client", mod_ctrl, "Down", f.shrink_top, "shrink the top of the window"),
  bindkey("client", mod_ctrl, "Up", f.shrink_bottom, "grow the top of the window"),
  bindkey("client", mod_ctrl, "Left", f.shrink_left, "shrink the right of the window"),
  bindkey("client", mod_ctrl, "Right", f.shrink_right, "grow the right of the window")
)
