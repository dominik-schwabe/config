local interpolate = require("util.interpolate")

local lain = require("lain")

local M = {}

function M.create()
  local last_was_highlighted = false
  return lain.widget.temp({
    timeout = 1,
    settings = function()
      local coretemp_now = coretemp_now
      local widget = widget
      local bg = "#000000"
      local fg
      local temp = tonumber(coretemp_now)
      if temp >= 85 then
        if last_was_highlighted then
          fg = "#FF0000"
        else
          bg = "#FF0000"
          fg = "#000000"
        end
        last_was_highlighted = not last_was_highlighted
      elseif temp >= 75 then
        fg = "#FF0000"
      elseif temp >= 65 then
        local stage = (coretemp_now - 65) / 10
        fg = interpolate.color(0xDEED12, 0xFF0000, stage)
      elseif temp >= 55 then
        local stage = (coretemp_now - 55) / 10
        fg = interpolate.color(0xFFFFFF, 0xDEED12, stage)
      else
        fg = "#ffffff"
      end
      local text = string.format("%2d", temp)
      text = lain.util.markup.fg(fg, text)
      text = text .. lain.util.markup.fg("#ffffff", "°C")
      text = lain.util.markup.bg(bg, text)
      widget:set_markup(text)
    end,
  })
end

return M
