local M = {}

local red_hex = 0xff0000
local green_hex = 0x00ff00
local blue_hex = 0x0000ff

function M.interpolate(i1, i2, stage)
  return math.floor(i1 + ((i2 - i1) * stage) + 0.5)
end

function M.color(c1, c2, stage)
  local color = (M.interpolate(c1 & red_hex, c2 & red_hex, stage) & red_hex)
    | (M.interpolate(c1 & green_hex, c2 & green_hex, stage) & green_hex)
    | (M.interpolate(c1 & blue_hex, c2 & blue_hex, stage) & blue_hex)
  return string.format("#%06x", color)
end

return M
