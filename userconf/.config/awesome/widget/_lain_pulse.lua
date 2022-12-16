local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local string = string
local events = require("events")

local F = require("util.functional")


local function factory(args)
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

return factory
