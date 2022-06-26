local send = require("repl.send")
local window = require("repl.window")
local S = require("repl.store")

local M = {}

local function set_default(param, default)
  return param ~= nil and param or default
end
-- preferred = require("myconfig.config").repls,
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

  local function send_buffer()
    send.buffer()
  end
  local function send_visual()
    send.visual()
  end
  local function send_line()
    send.line()
  end
  local function send_paragraph()
    send.paragraph()
  end
  local function toggle_repl()
    window.toggle_repl()
  end

  vim.keymap.set("n", "<C-space>", send_paragraph)
  vim.keymap.set("n", "<CR>", send_line)
  vim.keymap.set("x", "<CR>", send_visual)
  vim.keymap.set("n", "<leader><space>", send_buffer)
  vim.keymap.set({ "n", "i", "t" }, "<F4>", toggle_repl)
end

return M
