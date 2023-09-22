pcall(require, "luarocks.loader")

local vars = require("main.vars")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")
beautiful.wallpaper = vars.wallpaper
awful.util.shell = vars.shell
awful.mouse.snap.edge_enabled = false

local F = require("util.functional")
local notify = require("notify")

function D(arg, timeout)
  F.load("inspect", function(inspect)
    notify.info(inspect(arg), timeout)
  end)
end

function DK(list)
  if type(list) == "table" then
    D(F.keys(list))
  else
    D("--- object is not a table ---")
  end
end

function D0(arg)
  D(arg, 0)
end

local f = require("functions")

function DCB(instance)
  D0(f.dcb(instance))
end

function DCV(instance)
  D0(f.dcv(instance))
end

function DC(instance)
  D0(f.dc(instance))
end

function LC()
  D0(F.dict(F.map(client.get(), function(c)
    return {
      c.pid,
      c.name,
    }
  end)))
end

require("main.errors")
require("main.signals")

require("autofocus")

require("main.rules")

root.buttons(require("binding.globalbuttons"))
root.keys(require("binding.globalkeys"))

require("menubar").utils.terminal = vars.terminal -- set the terminal for applications that require it

require("deco.statusbar")

require("main.autostart")
