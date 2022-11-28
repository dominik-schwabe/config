local awful = require("awful")

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
end)

client.connect_signal("property::class", function(c)
  if c.class == "Spotify" then
    local tag = awful.tag.find_by_name(awful.screen[1], "7")
    c:move_to_tag(tag)
  end
end)

client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse_enter")
end)

local function update_properties(c)
  if client.focus ~= c then
    c.border_color = beautiful.border_normal
  else
    if c._border_color then
      c.border_color = c._border_color
    elseif c.floating then
      c.border_color = beautiful.border_focus_float
    else
      c.border_color = beautiful.border_focus
    end
    if c.floating then
      c:raise()
    end
  end
  if c.floating then
    c.border_width = c._border_width or beautiful.border_width
    if c._sticky then
      c.sticky = true
    end
  else
    c.sticky = false
  end
  local above = c.floating and not c.fullscreen
  c.below = not c.fullscreen and not above
  c.above = above
end

client.connect_signal("focus", update_properties)
client.connect_signal("unfocus", update_properties)
client.connect_signal("property::floating", update_properties)
client.connect_signal("property::fullscreen", update_properties)

client.connect_signal("property::sticky", function(c)
  if not c.sticky then
    c:move_to_tag(awful.screen.focused().selected_tag)
  end
end)

screen.connect_signal("arrange", function(s)
  local layout_name = s.selected_tag.layout.name
  local max = layout_name == "max"
  local only_one = #s.tiled_clients == 1
  for _, c in pairs(s.clients) do
    if not c.fullscreen then
      local pos = awful.client.idx(c)
      local is_first = pos and pos.col == 0
      if not c.floating then
        if is_first or max or only_one or c.maximized then
          c.border_width = 0
        else
          c.border_width = c._border_width or beautiful.border_width
        end
      end
    end
  end
end)

require("deco.titlebar")
