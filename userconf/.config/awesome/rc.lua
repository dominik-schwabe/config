package.path = package.path .. ";" .. os.getenv("HOME") .. "/.luarocks/share/lua/5.4/?.lua"
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.luarocks/share/lua/5.3/?.lua"
package.path = package.path .. ";" .. "/usr/share/lua/5.3/?.lua"
package.path = package.path .. ";" .. "/usr/share/lua/5.3/?/init.lua"

pcall(require, "luarocks.loader")

require("main.errors")
require("main.signals")

local root = root

local F = require("util.functional")
f = require("functions")

function DK(list)
  D(list ~= nil and F.keys(list) or nil)
end

function D(arg, timeout)
  require("naughty").notify({ text = require("inspect")(arg), timeout = timeout })
end

function D0(arg)
  D(arg, 0)
end

local vars = require("main.vars")

local awful = require("awful")
awful.util.shell = vars.shell

local gears = require("gears")
local beautiful = require("beautiful")

beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

require("awful.autofocus")

require("main.rules")

beautiful.wallpaper = vars.wallpaper

root.buttons(require("binding.globalbuttons"))
root.keys(require("binding.globalkeys"))

require("menubar").utils.terminal = vars.terminal -- Set the terminal for applications that require it

require("deco.statusbar")

require("main.autostart")
