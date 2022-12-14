pcall(require, "luarocks.loader")

package.path = package.path .. ";" .. os.getenv("HOME") .. "/.luarocks/share/lua/5.4/?.lua"
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.luarocks/share/lua/5.3/?.lua"
package.path = package.path .. ";" .. "/usr/share/lua/5.3/?.lua"
package.path = package.path .. ";" .. "/usr/share/lua/5.3/?/init.lua"

local naughty = require("naughty")

function D(arg, timeout)
  local inspect_loaded, inspect = pcall(require, "inspect")
  if inspect_loaded then
    naughty.notify({
      text = inspect(arg),
      timeout = timeout,
      screen = 1,
    })
  else
    naughty.notify({
      text = "unable to load inspect, please install it",
      timeout = 5,
      screen = 1,
    })
  end
end

local F = require("util.functional")

function DK(list)
  D(list ~= nil and F.keys(list) or nil)
end

function D0(arg)
  D(arg, 0)
end

f = require("functions")

function DC(instance)
  D0(f.dc(instance))
end

local root = root

local theme = require("theme")

require("main.errors")
require("main.signals")

local vars = require("main.vars")

local awful = require("awful")
awful.util.shell = vars.shell

local gears = require("gears")
local beautiful = require("beautiful")

beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

require("autofocus")

require("main.rules")

beautiful.wallpaper = vars.wallpaper

root.buttons(require("binding.globalbuttons"))
root.keys(require("binding.globalkeys"))

require("menubar").utils.terminal = vars.terminal -- Set the terminal for applications that require it

require("deco.statusbar")

require("main.autostart")

naughty.config.defaults.margin = theme.notification_margin
naughty.config.defaults.border_width = theme.notification_border_width
