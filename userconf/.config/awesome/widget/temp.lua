local interpolate = require("util.interpolate")

local color = require("util.color")

local M = {}

local function temp_formatter()
  local last_was_highlighted = false
  return function(temp)
    local bg = "#000000"
    local fg
    local text
    if temp == nil or temp == 0 then
      text = color.fg("#FF0000", "N/A")
    else
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
        local stage = (temp - 65) / 10
        fg = interpolate.color(0xDEED12, 0xFF0000, stage)
      elseif temp >= 55 then
        local stage = (temp - 55) / 10
        fg = interpolate.color(0xFFFFFF, 0xDEED12, stage)
      else
        fg = "#ffffff"
      end
      text = string.format("%2d", temp)
      text = color.fg(fg, text)
      text = text .. color.fg("#ffffff", "°C")
    end
    text = color.bg(bg, text)
    return text
  end
end

local cpu_formatter = temp_formatter()
local gpu_formatter = temp_formatter()

function M.create(lain)
  return lain.widget.temp({
    timeout = 1,
    settings = function()
      local coretemp_now = coretemp_now
      local temp_now = temp_now
      local widget = widget
      local gpu_key
      for key, value in pairs(temp_now) do
        if value == "GPU" then
          gpu_key = key:sub(1, -6) .. "input"
          break
        end
      end
      local gpu_temp = temp_now[gpu_key]
      local cpu_temp = tonumber(coretemp_now)
      local text = cpu_formatter(cpu_temp) .. " " .. gpu_formatter(gpu_temp)
      widget:set_markup(text)
    end,
  })
end

return M
