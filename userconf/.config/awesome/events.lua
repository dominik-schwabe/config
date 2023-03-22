local F = require("util.functional")

local events = {}

local function register(group, cb)
  if not events[group] then
    events[group] = {}
  end
  events[group][#events[group] + 1] = cb
end

local function call(group)
  local ve = events[group]
  if ve then
    F.foreach(ve, F.call)
  end
end

return { call = call, register = register }
