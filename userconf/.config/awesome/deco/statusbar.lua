local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local layouts = require("main.layouts")
local wibox = require("wibox")
local vars = require("main.vars")
local dpi = require("beautiful.xresources").apply_dpi

local color = require("util.color")
local F = require("util.functional")

local wibox_content = {
  layout = wibox.layout.fixed.horizontal,
}

local sep_left_start = wibox.widget.textbox(color.color("#ED9D12", "#000000", " ❰ "))
local sep_left = wibox.widget.textbox(color.color("#ED9D12", "#000000", "❰ "))
local sep_right = wibox.widget.textbox(color.color("#ED9D12", "#000000", " ❱ "))

local function add_wibox_content(content)
  content = F.compress(content)
  content = F.map(content, function(element)
    return { sep_left, element, sep_right }
  end)
  content = F.concat(table.unpack(content))
  local wibox_was_empty = #wibox_content == 0
  wibox_content = F.extend(wibox_content, content)
  if wibox_was_empty and #content > 0 then
    wibox_content[1] = sep_left_start
  end
end

local widgets = {}

widgets[2] = require("widget.stopwatch").create()
widgets[6] = require("widget.volume").create()
widgets[7] = wibox.widget.textclock(color.color("#F92782", "#000000", "%a %d.%m.%Y"), 1)
widgets[8] = wibox.widget.textclock(color.color("#DEED12", "#000000", "%H:%M"), 1)

F.load("lain", function(lain)
  widgets[1] = require("widget.net").create(lain)
  widgets[3] = require("widget.mem").create(lain)
  widgets[4] = require("widget.temp").create(lain)
  widgets[5] = require("widget.battery").create(lain)
end)

add_wibox_content(widgets)
wibox_content[#wibox_content + 1] = wibox.widget.systray()

local function set_wallpaper(s)
  if s.index == 1 and beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  else
    gears.wallpaper.fit(nil, s, "#000000")
  end
end

local function update_padding(s)
  if s.geometry.width > dpi(2000) or s.geometry.height > dpi(1500) then
    s.padding = 20
  else
    s.padding = 0
  end
end

screen.connect_signal("property::geometry", function(s)
  update_padding(s)
  set_wallpaper(s)
end)

screen.connect_signal("property::index", function(s)
  set_wallpaper(s)
end)

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
  update_padding(s)
  set_wallpaper(s)

  awful.tag({ "1", "2", "3", "4", "5", "6" }, s, layouts[1])
  if s.index == 1 then
    awful.tag.add("7", {
      screen = s,
      layout = layouts[2],
      selected = false,
    })
  end

  s.promptbox = awful.widget.prompt()

  s.taglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.noempty,
    buttons = taglist_buttons,
  })

  s.tasklist = awful.widget.tasklist({
    screen = s,
    filter = function(_client, _screen)
      local should_list = awful.widget.tasklist.filter.currenttags(_client, _screen)
      return should_list and not _client.sticky
    end,
    buttons = tasklist_buttons,
  })

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
    wibox_args[#wibox_args + 1] = wibox_content
  end
  s.wibox_bottom:setup(wibox_args)
end)
