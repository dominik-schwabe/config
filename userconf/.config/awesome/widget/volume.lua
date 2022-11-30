local lain = require("lain")

local M = {}

function M.create() -- TODO: replace with dbus alternative
  return lain.widget.pulse({
    timeout = 1,
    settings = function()
      local volume_now = volume_now
      local widget = widget
      local text
      if volume_now.left == "N/A" then
        text = lain.util.markup.color("#FF0000", "#000000", "N/A")
      else
        local fg
        local icon
        local muted = volume_now.muted == "yes"
        if muted then
          icon = "🔇"
          fg = "#FF0000"
        else
          icon = "🔊"
          fg = "#00FFFF"
        end
        local percent = lain.util.markup.fg("#ffffff", "%")
        if volume_now.left == volume_now.right then
          text = string.format("%2.f", volume_now.left)
          text = text .. percent
        else
          text = string.format("%2.%f", volume_now.left)
          text = text .. percent .. lain.util.markup.fg("#ffffff", "/")
          text = string.format("%2.%f", volume_now.right)
          text = text .. percent
        end
        text = icon .. " " .. text
        text = lain.util.markup.color(fg, "#000000", text)
      end
      widget:set_markup(text)
    end,
  })
end

return M
