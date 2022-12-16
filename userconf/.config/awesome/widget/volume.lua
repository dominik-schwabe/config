local lain = require("lain")
local lain_pulse = require("widget._lain_pulse")

local F = require("util.functional")

local M = {}

function M.create()
  return lain_pulse({
    timeout = 1,
    settings = function()
      local volume_now = volume_now
      local widget = widget
      local text
      if volume_now.volume == "N/A" then
        text = lain.util.markup.color("#FF0000", "#000000", "N/A")
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
        local percent = lain.util.markup.fg("#ffffff", "%")
        text = string.format("%2.f", volume_now.volume)
        text = speaker_icon .. " " .. text .. percent
        F.foreach(volume_now.mics, function(muted)
          local muted_icon
          if muted then
            muted_icon = lain.util.markup.fg("#FF0000", "")
          else
            muted_icon = lain.util.markup.fg("#00FF00", "")
          end
          text = text .. " " .. muted_icon
        end)
        text = lain.util.markup.color(fg, "#000000", text)
      end
      widget:set_markup(text)
    end,
  })
end

return M
