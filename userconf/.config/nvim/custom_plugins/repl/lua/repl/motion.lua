local M = {}

local window = require("repl.window")

function M.build_operatorfunc(ft)
  if ft == "" then
    ft = nil
  else
    ft = ft:sub(4)
  end
  return function(motion_type)
    window.send(ft, require("repl.utils").get_motion(motion_type))
  end
end

return M
