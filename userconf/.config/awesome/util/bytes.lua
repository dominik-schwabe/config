local M = {}

function M.convert(b)
  local num_digits = math.max(math.floor(math.log(b, 10)), 0)
  local lower_power = num_digits - num_digits % 3
  local order = lower_power / 3
  local unit
  local color
  if order <= 1 then
    order = 1
    unit = "K"
    color = "#FFFFFF"
  elseif order == 2 then
    unit = "M"
    color = "#00FFFF"
  elseif order == 3 then
    unit = "G"
    color = "#DEED12"
  elseif order == 4 then
    unit = "T"
    color = "#FF0000"
  elseif order == 5 then
    unit = "P"
    color = "#FF0000"
  elseif order == 6 then
    unit = "E"
    color = "#FF0000"
  elseif order == 7 then
    unit = "Z"
    color = "#FF0000"
  elseif order == 8 then
    unit = "Y"
    color = "#FF0000"
  end
  return {
    num = b / (1000 ^ order),
    unit = unit,
    color = color,
  }
end

return M
