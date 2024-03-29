local awful = require("awful")
local dpi = require("beautiful.xresources").apply_dpi
local F = require("util.functional")
local f = require("functions")

local function unfocus_sticky(c)
  if c.sticky and not c._dropdown_show and client.focus == c then
    client.focus = nil
  end
end

-- Theme handling library
local beautiful = require("beautiful")
client.connect_signal("manage", function(c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  if not awesome.startup then
    awful.client.setslave(c)
  end

  if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end

  if c.class == "Spotify" then
    c:connect_signal("property::urgent", function()
      if c.urgent then
        c.urgent = false
      end
    end)
  end
end)

client.connect_signal("property::maximized", function(c)
  if c.maximized then
    c.maximized = false
    client.focus = c
  end
end)

client.connect_signal("property::minimized", function(c)
  if c.minimized then
    c.minimized = false
    client.focus = c
  end
end)

client.connect_signal("mouse::leave", unfocus_sticky)

client.connect_signal("property::class", function(c)
  if c.class == "Spotify" then
    f.move_to_tag_name(c, "7")
  end
end)

client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse_enter")
end)

local function unfullscreen_all_other_clients_on_screen(c)
  F.foreach(c.screen.clients, function(e)
    if c ~= e and e.fullscreen then
      e.fullscreen = false
    end
  end)
end

local function update_border(c, s)
  if s and not c.fullscreen and not c.floating then
    local max = s.selected_tag.layout.name == "max"
    local only_one = #s.tiled_clients == 1
    local pos = awful.client.idx(c)
    local is_first = pos and pos.col == 0
    if not c.sticky and (is_first or max or only_one) then
      c.border_width = 0
      return
    else
      c.border_width = c._border_width or beautiful.border_width
    end
  end
  if c.floating then
    c.border_width = c._border_width or beautiful.border_width
  end
  if client.focus ~= c then
    if c.sticky and not c._border_color then
      c.border_color = "#999999"
    else
      c.border_color = beautiful.border_normal
    end
  else
    if c._border_color then
      c.border_color = c._border_color
    elseif c.sticky then
      c.border_color = "#ffffff"
    elseif c.floating then
      c.border_color = beautiful.border_focus_float
    else
      c.border_color = beautiful.border_focus
    end
  end
end

local function update_z_order(c)
  c.above = not c.fullscreen and c.floating
  c.below = not c.fullscreen and not c.floating
end

local function update_properties(c)
  update_border(c)
  update_z_order(c)
end

-- disallow the client from moving to far away from the edges of the screen
local offset = dpi(30)
client.connect_signal("property::geometry", function(c)
  if c.floating then
    local y_margin = offset - c.height
    local x_margin = offset - c.width
    f.no_offscreen(c, {
      margins = {
        top = y_margin,
        bottom = y_margin,
        left = x_margin,
        right = x_margin,
      },
    })
  end
end)

-- prevent fullscreen clients from losing focus (only necessary because of Spotify)
client.connect_signal("focus", function(c)
  if not c.floating and not c.fullscreen then
    local fullscreen_clients = F.filter(c.screen.clients, function(e)
      return e.fullscreen
    end)
    if #fullscreen_clients > 0 then
      client.focus = fullscreen_clients[1]
    end
  end
  c:raise()
  update_properties(c)
end)
client.connect_signal("unfocus", update_properties)
client.connect_signal("property::floating", function(c)
  c.sticky = false
  update_properties(c)
end)
client.connect_signal("property::sticky", function(c)
  update_border(c, c.screen)
end)

-- only one fullscreen client allowed per tag
client.connect_signal("property::fullscreen", function(c)
  if c.fullscreen then
    unfullscreen_all_other_clients_on_screen(c)
  end
  update_properties(c)
end)

-- keep sticky clients on the focused tag
tag.connect_signal("property::selected", function(t)
  if t.selected then
    local tag = awful.screen.focused().selected_tag
    F.foreach(client.get(), function(c)
      if c.sticky and tag.screen == c.screen then
        c:move_to_tag(tag)
      end
    end)
  end
end)

-- update borders based on clients position
screen.connect_signal("arrange", function(s)
  if not s.selected_tag then
    return
  end
  F.foreach(s.clients, function(c)
    update_border(c, s)
  end)
end)

local function filter_focus_func(c)
  return c.fullscreen or c.floating or #F.filter(c.screen.clients, function(e)
    return e.fullscreen
  end) == 0
end

client.connect_signal("request::activate", awful.client.focus.history.add)
awful.ewmh.add_activate_filter(filter_focus_func, "ewmh")
awful.ewmh.add_activate_filter(filter_focus_func, "rules")

require("deco.titlebar")
