local notify = require("notify")

local awesome = awesome

if awesome.startup_errors then
  notify.error(awesome.startup_errors, "ERROR (startup)")
end

local function register_error_handler(error_type)
  local in_error = false
  local event = "debug::" .. error_type
  local title = "ERROR (" .. event .. ")"
  awesome.connect_signal(event, function(err)
    if in_error then
      return
    end
    in_error = true
    notify.error(tostring(err), title)
    in_error = false
  end)
end

register_error_handler("debug::error")
register_error_handler("debug::deprecation")
register_error_handler("debug::index::miss")
register_error_handler("debug::newindex::miss")
