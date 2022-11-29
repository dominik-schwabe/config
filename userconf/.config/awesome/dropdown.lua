local awful = require("awful")
local F = require("util.functional")
local f = require("functions")
local beautiful = require("beautiful")

local client = client

local groups = {}
local managed_clients = {}

local function hide_group(c)
  if c._group then
    F.foreach(groups[c._group], function(e)
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

local function other_has_focus(c)
  return F.any(managed_clients, function(e)
    return c ~= e and client.focus == e
  end)
end

local function should_show(c)
  local current_tag = f.focused_tag()
  local was_different_tag = not c.hidden and not c.sticky and current_tag and not client_is_on_tag(c, current_tag)
  return c.hidden or was_different_tag
end

local function option_applier(config)
  return function(c, show)
    if show == nil then
      show = should_show(c) or (client.focus and client.focus.fullscreen) or other_has_focus(c)
    end
    c.hidden = not show
    c.floating = show
    c.sticky = show
    c.above = show
    c.border_width = c._border_width or beautiful.border_width
    c.border_color = c._border_color or beautiful.border_focus_float
    f.to_first(c)
    if show then
      f.set_geometry(c, config)
      client.focus = c
      hide_group(c)
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
  local dropdown_show = option_applier(config)
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
      if border_width then
        c._border_width = border_width
      end
      c._is_dropdown = true
      c._sticky = true
      if group then
        c._group = group
        local clients = groups[group] or {}
        clients[#clients + 1] = c
        groups[group] = clients
      end
      managed_clients[#managed_clients + 1] = c
      c._dropdown_show = function(show)
        dropdown_show(c, show)
      end
      c._dropdown_show(config.cmd ~= nil)
      if not config.cmd then
        c.hidden = true
      end
    end
  end)
  return toggle
end

client.connect_signal("unmanage", function(c)
  if c._is_dropdown then
    if c._group then
      groups[c._group] = F.remove(groups[c._group], c)
    end
    managed_clients = F.remove(managed_clients, c)
  end
end)

return {
  build_toggle_dropdown = build_toggle_dropdown,
}
