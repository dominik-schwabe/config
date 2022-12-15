local lain = require("lain")
local lain_pulse = require("widget._lain_pulse")

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
        local icon
        if volume_now.muted then
          icon = "🔇"
          fg = "#FF0000"
        else
          icon = "🔊"
          fg = "#00FFFF"
        end
        local percent = lain.util.markup.fg("#ffffff", "%")
        text = string.format("%2.f", volume_now.volume)
        text = icon .. " " .. text .. percent
        text = lain.util.markup.color(fg, "#000000", text)
      end
      widget:set_markup(text)
    end,
  })
end

return M
