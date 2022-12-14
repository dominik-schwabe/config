local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local lain = require("lain")

local M = {}

function M.create()
  local stopwatch = wibox.widget.textbox()
  local total_seconds = 0
  local state = "reset"
  local timer = gears.timer({ timeout = 1 })
  local function stopwatch_update()
    local bg = "#000000"
    local fg = "#FFFFFF"
    if state == "running" then
      fg = "#00FF00"
    elseif state == "stopped" then
      fg = "#000000"
      bg = "#FF0000"
    end
    local minutes = math.floor(total_seconds / 60)
    local hours = math.floor(minutes / 60)
    minutes = minutes - hours * 60
    local text = string.format("%d:%02d", hours, minutes)
    text = lain.util.markup.color(fg, bg, text)
    stopwatch:set_markup(text)
  end
  timer:connect_signal("start", function()
    state = "running"
    stopwatch_update()
  end)
  timer:connect_signal("stop", function()
    state = "stopped"
    stopwatch_update()
  end)
  timer:connect_signal("timeout", function()
    total_seconds = total_seconds + 1
    stopwatch_update()
  end)
  stopwatch:buttons(gears.table.join(
    awful.button({}, 1, function()
      if state == "running" then
        timer:stop()
      else
        timer:start()
      end
    end),
    awful.button({}, 3, function()
      timer:stop()
      total_seconds = 0
      state = "reset"
      stopwatch_update()
    end)
  ))
  stopwatch_update()
  return stopwatch
end

return M
