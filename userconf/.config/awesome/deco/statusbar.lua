local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local layouts = require("main.layouts")
local wibox = require("wibox")
local vars = require("main.vars")
local dpi = require("beautiful.xresources").apply_dpi

local screen = screen
local client = client

local lain = require("lain")

local timebox = wibox.widget.textclock(lain.util.markup.color("#DEED12", "#000000", "%H:%M"))
local datebox = wibox.widget.textclock(lain.util.markup.color("#F92782", "#000000", "%a %d.%m.%Y"))
local sep_mid = wibox.widget.textbox(lain.util.markup.color("#ED9D12", "#000000", " ❱ ❰ "))
local sep_right = wibox.widget.textbox(lain.util.markup.color("#ED9D12", "#000000", " ❱ "))
local sep_left = wibox.widget.textbox(lain.util.markup.color("#ED9D12", "#000000", " ❰ "))

local stopwatch = require("widget.stopwatch").create()
local net = require("widget.net").create()
local volume = require("widget.volume").create()
local mem = require("widget.mem").create()
local temp = require("widget.temp").create()
local battery = require("widget.battery").create()

local systray = wibox.widget.systray()

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

screen.connect_signal("property::geometry", set_wallpaper)

local mod = { vars.modkey }

local taglist_buttons = gears.table.join(
  awful.button({}, 1, function(t)
    t:view_only()
  end),
  awful.button(mod, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({}, 2, awful.tag.viewtoggle),
  awful.button(mod, 2, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end)
)

local tasklist_buttons = gears.table.join(awful.button({}, 1, function(c)
  if c ~= client.focus then
    c:emit_signal("request::activate", "tasklist", { raise = true })
  end
end))

awful.layout.layouts = layouts

awful.screen.connect_for_each_screen(function(s)
  -- s.padding = -1
  -- Wallpaper

  awful.tag({ "1", "2", "3", "4", "5", "6" }, s, layouts[1])
  if s.index == 1 then
    set_wallpaper(s)
    awful.tag.add("7", {
      screen = s,
      layout = layouts[2],
      selected = false,
    })
  else
    gears.wallpaper.set("#000000")
  end

  -- Create a promptbox for each screen
  s.promptbox = awful.widget.prompt()
  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  -- s.layoutbox = awful.widget.layoutbox(s)
  -- s.layoutbox:buttons(gears.table.join(
  --   awful.button({}, 1, function()
  --     awful.layout.inc(1)
  --   end),
  --   awful.button({}, 3, function()
  --     awful.layout.inc(-1)
  --   end),
  --   awful.button({}, 4, function()
  --     awful.layout.inc(1)
  --   end),
  --   awful.button({}, 5, function()
  --     awful.layout.inc(-1)
  --   end)
  -- ))

  -- Create a taglist widget
  s.taglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.noempty,
    buttons = taglist_buttons,
  })

  -- Create a tasklist widget
  s.tasklist = awful.widget.tasklist({
    screen = s,
    filter = function(_client, _screen)
      local should_list = awful.widget.tasklist.filter.currenttags(_client, _screen)
      return should_list and not _client.sticky
    end,
    buttons = tasklist_buttons,
  })

  -- Create the wibox
  s.wibox_bottom = awful.wibar({
    position = "bottom",
    screen = s,
    border_width = 0,
    height = dpi(18),
    bg = "#000000",
    fg = "#ffffff",
  })

  local wibox_args = {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      s.taglist,
      s.promptbox,
    },
    s.tasklist,
  }
  if s.index == 1 then
    wibox_args[#wibox_args + 1] = {
      layout = wibox.layout.fixed.horizontal,
      sep_left,
      net.widget,
      sep_mid,
      stopwatch,
      sep_mid,
      mem,
      sep_mid,
      temp,
      sep_mid,
      battery,
      sep_mid,
      volume,
      sep_mid,
      datebox,
      sep_mid,
      timebox,
      sep_right,
      systray,
    }
  end
  s.wibox_bottom:setup(wibox_args)
end)
