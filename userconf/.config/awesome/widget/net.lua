local F = require("util.functional")
local convert_bytes = require("util.bytes").convert

local color = require("util.color")

local M = {}

function M.create(lain)
  local is_first_net = true
  return lain.widget.net({
    timeout = 3,
    notify = "off",
    units = 1,
    settings = function()
      local net_now = net_now
      local widget = widget
      local text
      local all_sent = 0
      local all_received = 0
      local is_up = F.any(F.values(net_now.devices), function(e)
        return e.state == "up"
      end)
      if is_first_net then
        is_first_net = false
        text = color.color("#FF0000", "#000000", "- - - -")
      else
        for _, v in pairs(net_now.devices) do
          all_sent = all_sent + v.last_t
          all_received = all_received + v.last_r
        end
        if is_up then
          text = table.concat(
            F.map({ net_now.sent, all_sent, net_now.received, all_received }, function(bytes)
              local representation = convert_bytes(bytes)
              local num = representation.num
              local unit = representation.unit
              local col = representation.color
              return color.fg(col, string.format("%3.f%s", num, unit))
            end),
            " "
          )
          text = color.color("#ffffff", "#000000", text)
        else
          text = color.color("#FF0000", "#000000", "DOWN")
        end
      end
      widget:set_markup(text)
    end,
  }).widget
end

return M
