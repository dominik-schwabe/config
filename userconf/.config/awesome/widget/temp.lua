local interpolate = require("util.interpolate")

local lain = require("lain")

local M = {}

function M.create()
  return lain.widget.temp({
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
            fg = interpolate.color(0xFFFFFF, 0xDEED12, stage)
          else
            local stage = (coretemp_now - 65) / 10
            fg = interpolate.color(0xDEED12, 0xFF0000, stage)
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
end

return M
