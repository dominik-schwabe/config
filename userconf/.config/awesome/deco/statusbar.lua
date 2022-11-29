local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local layouts = require("main.layouts")
local wibox = require("wibox")
local vars = require("main.vars")

local screen = screen
local client = client

local F = require("util.functional")

local lain = require("lain")

local red_hex = 0xff0000
local green_hex = 0x00ff00
local blue_hex = 0x0000ff
local function interpolate(i1, i2, stage)
  return math.floor(i1 + ((i2 - i1) * stage) + 0.5)
end
local function interpolate_color(c1, c2, stage)
  local color = (interpolate(c1 & red_hex, c2 & red_hex, stage) & red_hex)
    | (interpolate(c1 & green_hex, c2 & green_hex, stage) & green_hex)
    | (interpolate(c1 & blue_hex, c2 & blue_hex, stage) & blue_hex)
  return string.format("#%06x", color)
end

local timebox = wibox.widget.textclock(lain.util.markup.color("#DEED12", "#000000", "%H:%M"))
local datebox = wibox.widget.textclock(lain.util.markup.color("#F92782", "#000000", "%a %d.%m.%Y"))
local sep_mid = wibox.widget.textbox(lain.util.markup.color("#ED9D12", "#000000", " ❱ ❰ "))
local sep_right = wibox.widget.textbox(lain.util.markup.color("#ED9D12", "#000000", " ❱ "))
local sep_left = wibox.widget.textbox(lain.util.markup.color("#ED9D12", "#000000", " ❰ "))

local stopwatch = wibox.widget.textbox()
local total_seconds = 0
local state = "reset"
local timer = gears.timer({ timeout = 1 })
local function stopwatch_update()
  local fg = "#FFFFFF"
  if state == "running" then
    fg = "#00FF00"
  elseif state == "stopped" then
    fg = "#FF0000"
  end
  local minutes = math.floor(total_seconds / 60)
  local hours = math.floor(minutes / 60)
  minutes = minutes - hours * 60
  local text = string.format("%d:%02d", hours, minutes)
  text = lain.util.markup.color(fg, "#000000", text)
  stopwatch:set_markup(text)
end
timer:connect_signal("start", function()
  state = "running"
  stopwatch_update()
end)
timer:connect_signal("stop", function()
  state = "stopped"
  stopwatch_update()
end)
timer:connect_signal("timeout", function()
  total_seconds = total_seconds + 1
  stopwatch_update()
end)
stopwatch:buttons(gears.table.join(
  awful.button({}, 1, function()
    if state == "running" then
      timer:stop()
    else
      timer:start()
    end
  end),
  awful.button({}, 3, function()
    timer:stop()
    total_seconds = 0
    state = "reset"
    stopwatch_update()
  end)
))
stopwatch_update()

local function convert_bytes(b)
  local num_digits = math.floor(math.log10(b))
  local lower_power = num_digits - num_digits % 3
  local order = lower_power / 3
  local unit
  local color
  if order <= 1 then
    order = 1
    unit = "KB"
    color = "#FFFFFF"
  elseif order == 2 then
    unit = "MB"
    color = "#00FFFF"
  elseif order == 3 then
    unit = "GB"
    color = "#DEED12"
  elseif order == 4 then
    unit = "TB"
    color = "#FF0000"
  elseif order == 5 then
    unit = "PB"
    color = "#FF0000"
  elseif order == 6 then
    unit = "EB"
    color = "#FF0000"
  elseif order == 7 then
    unit = "ZB"
    color = "#FF0000"
  elseif order == 8 then
    unit = "YB"
    color = "#FF0000"
  end
  return {
    num = b / math.pow(1000, order),
    unit = unit,
    color = color,
  }
end

local is_first_net = true
local mynet = lain.widget.net({
  timeout = 3,
  notify = "off",
  units = 1,
  settings = function()
    local net_now = net_now
    local widget = widget
    local text
    local all_sent = 0
    local all_received = 0
    local is_up = F.any(F.values(net_now.devices), function(e)
      return e.state == "up"
    end)
    if is_first_net then
      is_first_net = false
      text = lain.util.markup.color("#FF0000", "#000000", "- - - -")
    else
      for _, v in pairs(net_now.devices) do
        all_sent = all_sent + v.last_t
        all_received = all_received + v.last_r
      end
      if is_up then
        text = table.concat(
          F.map({ net_now.sent, all_sent, net_now.received, all_received }, function(bytes)
            local representation = convert_bytes(bytes)
            local num = representation.num
            local unit = representation.unit
            local color = representation.color
            return lain.util.markup.fg(color, string.format("%3.f%s", num, unit))
          end),
          " "
        )
        text = lain.util.markup.color("#ffffff", "#000000", text)
      else
        text = lain.util.markup.color("#FF0000", "#000000", "DOWN")
      end
    end
    widget:set_markup(text)
  end,
})
local volume = lain.widget.pulse({
  timeout = 1,
  settings = function()
    local volume_now = volume_now
    local widget = widget
    local text
    if volume_now.left == "N/A" then
      text = lain.util.markup.color("#FF0000", "#000000", "N/A")
    else
      local fg
      local icon
      local muted = volume_now.muted == "yes"
      if muted then
        icon = "🔇"
        fg = "#FF0000"
      else
        icon = "🔊"
        fg = "#00FFFF"
      end
      local percent = lain.util.markup.fg("#ffffff", "%")
      if volume_now.left == volume_now.right then
        text = string.format("%2.f", volume_now.left)
        text = text .. percent
      else
        text = string.format("%2.%f", volume_now.left)
        text = text .. percent .. lain.util.markup.fg("#ffffff", "/")
        text = string.format("%2.%f", volume_now.right)
        text = text .. percent
      end
      text = icon .. " " .. text
      text = lain.util.markup.color(fg, "#000000", text)
    end
    widget:set_markup(text)
  end,
})
local mymem = lain.widget.mem({
  timeout = 2,
  unit = 1000,
  settings = function()
    local mem_now = mem_now
    local widget = widget
    local fg = "#00FFFF"
    if not mem_now.perc then
      return
    end
    if mem_now.perc > 80 then
      fg = "#FF0000"
    elseif mem_now.perc > 50 then
      fg = "#DEED12"
    end
    local text = string.format("%2d", mem_now.perc)
      .. lain.util.markup.fg("#ffffff", "% (")
      .. string.format("%2.1f", mem_now.total * 1024 / 1000 / 1000)
      .. lain.util.markup.fg("#ffffff", "GB)")
    text = lain.util.markup.color(fg, "#000000", text)
    widget:set_markup(text)
  end,
})
local mytemp = lain.widget.temp({
  timeout = 2,
  settings = function()
    local coretemp_now = coretemp_now
    local widget = widget
    local fg = "#ffffff"
    local temp = tonumber(coretemp_now)
    if temp > 55 then
      if temp > 75 then
        fg = "#FF0000"
      else
        if temp < 65 then
          local stage = (coretemp_now - 55) / 10
          fg = interpolate_color(0xFFFFFF, 0xDEED12, stage)
        else
          local stage = (coretemp_now - 65) / 10
          fg = interpolate_color( 0xDEED12, 0xFF0000, stage)
        end
      end
    end
    local text = string.format("%2d", temp)
    text = lain.util.markup.fg(fg, text)
    text = text .. lain.util.markup.fg("#ffffff", "°C")
    text = lain.util.markup.bg("#000000", text)
    widget:set_markup(text)
  end,
})

local glyphs = { "", "", "", "", "", "", "", "", "", "", "" }
local mybattery = lain.widget.bat({
  timeout = 1,
  full_notify = "off",
  settings = function()
    local bat_now = bat_now
    local widget = widget
    local fg = "#00FF00"
    local bg = "#000000"
    local text
    if bat_now.status == "N/A" then
      fg = "#FF0000"
      text = "N/A"
    else
      if bat_now.status == "Full" or bat_now.status == "Not charging" then
        text = string.format("%3d", bat_now.perc)
      else
        text = string.format("%2d", bat_now.perc)
        local glyph
        if bat_now.status == "Charging" then
          glyph = lain.util.markup.color("#DEED12", bg, "")
        else
          glyph = glyphs[math.ceil(bat_now.perc / (100 / #glyphs))]
        end
        text = glyph .. " " .. text
      end
      if bat_now.status == "Discharging" then
        if bat_now.perc <= 5 then
          bg = "#FF0000"
          fg = "#000000"
        elseif bat_now.perc <= 15 then
          fg = "#FF0000"
        else
          local stage = (bat_now.perc - 15) / 85
          fg = interpolate_color(0xFF0000, 0xDEED12, stage)
        end
      end
      text = lain.util.markup.fg(fg, text)
      if bat_now.status ~= "N/A" then
        text = text .. "%"
      end
      text = lain.util.markup.color("#ffffff", bg, text)
      widget:set_markup(text)
    end
  end,
})
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

local tasklist_buttons = gears.table.join(awful.button({}, 1, function(c)
  if c ~= client.focus then
    c:emit_signal("request::activate", "tasklist", { raise = true })
  end
end))

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
    filter = function(_client, _screen)
      local should_list = awful.widget.tasklist.filter.currenttags(_client, _screen)
      return should_list and not _client._is_dropdown and not _client.sticky
    end,
    buttons = tasklist_buttons,
  })

  -- Create the wibox
  s.wibox_bottom = awful.wibar({
    position = "bottom",
    screen = s,
    border_width = 0,
    height = 20,
    bg = "#000000",
    fg = "#ffffff",
  })

  -- Add widgets to the wibox
  s.wibox_bottom:setup({
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      s.taglist,
      s.promptbox,
    },
    s.tasklist, -- Middle widget
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      sep_left,
      mynet.widget,
      sep_mid,
      stopwatch,
      sep_mid,
      mymem,
      sep_mid,
      mytemp,
      sep_mid,
      mybattery,
      sep_mid,
      volume,
      sep_mid,
      datebox,
      sep_mid,
      timebox,
      sep_right,
      systray,
    },
  })
end)
