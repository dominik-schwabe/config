package.path = package.path .. ";" .. os.getenv("HOME") .. "/.luarocks/share/lua/5.4/?.lua"
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.luarocks/share/lua/5.3/?.lua"
package.path = package.path .. ";" .. "/usr/share/lua/5.3/?.lua"
package.path = package.path .. ";" .. "/usr/share/lua/5.3/?/init.lua"

pcall(require, "luarocks.loader")

local root = root

local F = require("util.functional")

function DK(list)
  D(list ~= nil and F.keys(list) or nil)
end

function D(arg)
  require("naughty").notify({ text = require("inspect")(arg) })
end

local vars = require("main.vars")

local awful = require("awful")
awful.util.shell = vars.shell

local gears = require("gears")
local beautiful = require("beautiful")

beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

require("awful.hotkeys_popup.keys")
require("awful.autofocus")

require("main.errors")
require("main.rules")

beautiful.wallpaper = vars.wallpaper

root.buttons(require("binding.globalbuttons"))
root.keys(require("binding.globalkeys"))

require("menubar").utils.terminal = vars.terminal -- Set the terminal for applications that require it

require("deco.statusbar")

require("main.signals")

require("main.autostart")
