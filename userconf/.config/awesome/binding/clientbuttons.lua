local awful = require("awful")
local gears = require("gears")
local vars = require("main.vars")

local f = require("functions")

local mod = { vars.modkey }

return gears.table.join(
  awful.button({}, 1, f.click),
  awful.button(mod, 1, f.click_move),
  awful.button(mod, 3, f.click_resize)
)
