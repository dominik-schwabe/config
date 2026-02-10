local S = require("repl.store")

local M = {}

function M.setup(config)
  config = vim.F.if_nil(config, {})
  S.preferred = vim.F.if_nil(config.preferred, {})
  S.term_name = vim.F.if_nil(config.term_name, "term://repl")
  S.listed = vim.F.if_nil(config.listed, false)
  S.debug = vim.F.if_nil(config.debug, false)
  S.ensure_win = vim.F.if_nil(config.ensure_win, true)
  S.after_open = config.after_open
  S.on_stdout = config.on_stdout

  require("repl.store").set_callbacks(config.callbacks)
end

return M
