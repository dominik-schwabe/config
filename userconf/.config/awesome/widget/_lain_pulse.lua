local F = require("util.functional")
local awful = require("awful")
-- local shell = require("awful.util").shell
local gears = require("gears")
local wibox = require("wibox")
local string = string
local events = require("events")

-- PulseAudio volume
-- lain.widget.pulse

local function factory(args)
  args = args or {}

  local pulse = { widget = args.widget or wibox.widget.textbox(), device = "N/A" }
  local timeout = args.timeout or 5
  local settings = args.settings or function() end

  pulse.cmd = "pamixer --get-volume --get-mute"

  function pulse.update()
    awful.spawn.easy_async_with_shell(pulse.cmd, function(out, _, _, exit_code)
      local muted = "N/A"
      local volume = "N/A"
      if exit_code == 0 then
        muted, volume = table.unpack(F.consume(string.gmatch(out, "%S+")))
      end
      volume_now = {
        volume = volume,
        muted = muted == "true",
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
