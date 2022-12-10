local awful = require("awful")
local dpi = require("beautiful.xresources").apply_dpi
local F = require("util.functional")
local f = require("functions")
local beautiful = require("beautiful")

local client = client

local groups = {}

local function hide_group(c, group)
  if group then
    F.foreach(groups[group], function(e)
      if c ~= e then
        e._dropdown_show(false)
      end
    end)
  end
end

local function client_is_on_tag(c, tag)
  for _, t in pairs(c:tags()) do
    if t == tag then
      return true
    end
  end
  return false
end

local function should_show(c)
  local current_tag = f.focused_tag()
  local was_different_tag = not c.hidden and not c.sticky and current_tag and not client_is_on_tag(c, current_tag)
  return c.hidden or was_different_tag
end

local function option_applier(c, config)
  return function(show)
    if show == nil then
      local cf = client.focus
      show = should_show(c) or (cf and c ~= cf and (cf.fullscreen or cf.floating))
    end
    c.hidden = not show
    c.floating = show
    c.sticky = show
    c.above = show
    c.border_width = c._border_width or beautiful.border_width
    c.border_color = c._border_color or beautiful.border_focus_float
    f.move_to_tag_name(c, "1")
    if show then
      f.set_geometry(c, config)
      client.focus = c
      hide_group(c, config.group)
    end
  end
end

local function client_matcher(config)
  local match_args = {
    name = config.name,
    instance = config.instance,
    class = config.class,
  }
  return function(c)
    for key, value in pairs(match_args) do
      local field = c[key]
      if not field or not field:match(value) then
        return false
      end
    end
    return true
  end
end

local function build_toggle_dropdown(config)
  local matcher = client_matcher(config)
  local border_color = config.border_color
  local border_width = config.border_width
  local group = config.group
  local function toggle()
    local cmd = config.cmd

    local dropdown_client = F.next(awful.client.iterate(matcher))

    if not dropdown_client then
      if cmd then
        awful.spawn.with_shell(cmd)
      end
      return
    end
    dropdown_client._dropdown_show()
  end
  client.connect_signal("manage", function(c)
    if matcher(c) then
      if border_color then
        c._border_color = border_color
      end
      c.skip_taskbar = true
      if border_width then
        c._border_width = dpi(border_width)
      end
      c:connect_signal("property::floating", function()
        c.sticky = c.floating
      end)
      if group then
        local clients = groups[group] or {}
        clients[#clients + 1] = c
        groups[group] = clients
        c:connect_signal("unmanage", function()
          groups[group] = F.remove(groups[group], c)
        end)
      end
      c._dropdown_show = option_applier(c, config)
      c._dropdown_show(config.cmd ~= nil)
      if not config.cmd then
        c.hidden = true
      end
    end
  end)
  return toggle
end

return {
  build_toggle_dropdown = build_toggle_dropdown,
}
