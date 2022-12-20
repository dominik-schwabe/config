local interpolate = require("util.interpolate")

local color = require("util.color")

local M = {}

function M.create(lain)
  return lain.widget.mem({
    timeout = 2,
    unit = 1000,
    settings = function()
      local mem_now = mem_now
      local widget = widget
      local fg
      if not mem_now.perc then
        return
      end
      if mem_now.perc < 20 then
        fg = "#ffffff"
      elseif mem_now.perc < 50 then
        local stage = (mem_now.perc - 20) / 30
        fg = interpolate.color(0xFFFFFF, 0xDEED12, stage)
      elseif mem_now.perc < 90 then
        local stage = (mem_now.perc - 50) / 40
        fg = interpolate.color(0xDEED12, 0xFF0000, stage)
      else
        fg = "#FF0000"
      end
      local text = string.format("%2d", mem_now.perc)
        .. color.fg("#ffffff", "% (")
        .. color.fg("#00FFFF", string.format("%2.1f", mem_now.total * 1024 / 1000 / 1000))
        .. color.fg("#ffffff", "G)")
      text = color.color(fg, "#000000", text)
      widget:set_markup(text)
    end,
  })
end

return M
