local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local string = string
local events = require("events")

local color = require("util.color")
local F = require("util.functional")

local function pipewire(args)
  args = args or {}

  local pulse = { widget = args.widget or wibox.widget.textbox(), device = "N/A" }
  local timeout = args.timeout or 5
  local settings = args.settings or function() end

  function pulse.update()
    awful.spawn.easy_async_with_shell("volume_info", function(out, _, _, exit_code)
      local muted = "N/A"
      local volume = "N/A"
      local mics = {}
      if exit_code == 0 then
        local iter = string.gmatch(out, "%S+")
        muted = iter()
        volume = iter()
        mics = F.map(F.consume(iter), function(e)
          return e == "true"
        end)
      end
      volume_now = {
        volume = volume,
        muted = muted == "true",
        mics = mics,
      }

      widget = pulse.widget
      settings()
    end)
  end

  local timer = gears.timer({ timeout = timeout })

  events.register("volume", function()
    timer:emit_signal("timeout")
  end)

  timer:start()
  timer:connect_signal("timeout", pulse.update)
  timer:emit_signal("timeout")

  return pulse
end

local M = {}

function M.create()
  return pipewire({
    timeout = 1,
    settings = function()
      local volume_now = volume_now
      local widget = widget
      local text
      if volume_now.volume == "N/A" then
        text = color.color("#FF0000", "#000000", "N/A")
      else
        local fg
        local speaker_icon
        if volume_now.muted then
          speaker_icon = "🔇"
          fg = "#FF0000"
        else
          speaker_icon = "🔊"
          fg = "#00FFFF"
        end
        local percent = color.fg("#ffffff", "%")
        text = string.format("%2.f", volume_now.volume)
        text = speaker_icon .. " " .. text .. percent
        F.foreach(volume_now.mics, function(muted)
          local muted_icon
          if muted then
            muted_icon = color.fg("#FF0000", "")
          else
            muted_icon = color.fg("#00FF00", "")
          end
          text = text .. " " .. muted_icon
        end)
        text = color.color(fg, "#000000", text)
      end
      widget:set_markup(text)
    end,
  })
end

return M
