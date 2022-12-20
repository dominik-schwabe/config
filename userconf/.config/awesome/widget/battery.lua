local interpolate = require("util.interpolate")

local color = require("util.color")

local M = {}

local glyphs = { "", "", "", "", "", "", "", "", "", "", "" }

function M.create(lain)
  local last_was_highlighted = false
  return lain.widget.bat({
    timeout = 1,
    full_notify = "off",
    settings = function()
      local bat_now = bat_now
      local widget = widget
      local fg = "#00FF00"
      local bg = "#000000"
      local text
      if bat_now.status == "N/A" then
        fg = "#FF0000"
        text = "N/A"
      else
        if bat_now.status == "Full" or bat_now.status == "Not charging" then
          text = string.format("%3d", bat_now.perc)
        else
          text = string.format("%2d", bat_now.perc)
          local glyph
          if bat_now.status == "Charging" then
            glyph = color.color("#DEED12", bg, "")
          else
            glyph = glyphs[math.ceil(bat_now.perc / (100 / #glyphs))]
          end
          text = glyph .. " " .. text
        end
        if bat_now.status == "Discharging" then
          if bat_now.perc <= 20 then
            if last_was_highlighted then
              bg = "#000000"
              fg = "#FF0000"
            else
              bg = "#FF0000"
              fg = "#000000"
            end
            last_was_highlighted = not last_was_highlighted
          elseif bat_now.perc <= 30 then
            bg = "#FF0000"
            fg = "#000000"
          else
            local stage = (bat_now.perc - 30) / 70
            fg = interpolate.color(0xFF0000, 0xDEED12, stage)
          end
        end
      end
      text = color.fg(fg, text)
      if bat_now.status ~= "N/A" then
        text = text .. "%"
      end
      text = color.color("#ffffff", bg, text)
      widget:set_markup(text)
    end,
  })
end

return M
