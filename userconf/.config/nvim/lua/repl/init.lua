local S = require("repl.store")

local M = {}

local function set_default(param, default)
  return param ~= nil and param or default
end
-- preferred = require("user.config").repls,
-- close_window_on_exit = true,
-- repl_definition
function M.setup(config)
  config = set_default(config, {})
  S.preferred = set_default(config.preferred, {})
  S.term_name = set_default(config.term_name, "term://repl")
  S.listed = set_default(config.listed, false)
  S.debug = set_default(config.debug, false)
  S.ensure_win = set_default(config.ensure_win, true)

  require("repl.store").set_callbacks(config.callbacks)
end

return M
