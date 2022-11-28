local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local layouts = require("main.layouts")
local wibox = require("wibox")
local vars = require("main.vars")

-- Create a launcher widge
local launcher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = require("main.menu") })

-- Keyboard map indicator and switcher
-- local keyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
local textclock = wibox.widget.textclock()

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
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button(mod, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({}, 4, function(t)
    awful.tag.viewnext(t.screen)
  end),
  awful.button({}, 5, function(t)
    awful.tag.viewprev(t.screen)
  end)
)

local tasklist_buttons = gears.table.join(
  awful.button({}, 1, function(c)
    if c ~= client.focus then
      c:emit_signal("request::activate", "tasklist", { raise = true })
    end
  end),
  awful.button({}, 3, function()
    awful.menu.client_list({ theme = { width = 250 } })
  end),
  awful.button({}, 4, function()
    awful.client.focus.byidx(1)
  end),
  awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
  end)
)

awful.layout.layouts = layouts

awful.screen.connect_for_each_screen(function(s)
  -- s.padding = -1
  -- Wallpaper
  set_wallpaper(s)

  -- Each screen has its own tag table.
  awful.tag({ "1", "2", "3", "4", "5", "6" }, s, layouts[1])
  awful.tag.add("7", {
    screen = s,
    layout = layouts[2],
    selected = false,
  })

  -- Create a promptbox for each screen
  s.promptbox = awful.widget.prompt()
  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.layoutbox = awful.widget.layoutbox(s)
  s.layoutbox:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.layout.inc(1)
    end),
    awful.button({}, 3, function()
      awful.layout.inc(-1)
    end),
    awful.button({}, 4, function()
      awful.layout.inc(1)
    end),
    awful.button({}, 5, function()
      awful.layout.inc(-1)
    end)
  ))
  -- Create a taglist widget
  s.taglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.noempty,
    buttons = taglist_buttons,
  })

  -- Create a tasklist widget
  s.tasklist = awful.widget.tasklist({
    screen = s,
    filter = awful.widget.tasklist.filter.currenttags,
    buttons = tasklist_buttons,
  })

  -- Create the wibox
  s.wibox_bottom = awful.wibar({ position = "bottom", screen = s })

  local systray = wibox.widget.systray()
  systray.opacity = 0.2
  -- Add widgets to the wibox
  s.wibox_bottom:setup({
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      launcher,
      s.taglist,
      s.promptbox,
    },
    s.tasklist, -- Middle widget
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      textclock,
      systray,
    },
  })
end)
