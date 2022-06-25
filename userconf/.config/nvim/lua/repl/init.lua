local send = require("repl.send")
local window = require("repl.window")
local S = require("repl.store")

local M = {}

-- preferred = require("myconfig.config").repls,
-- close_window_on_exit = true,
-- repl_definition
function M.setup(config)
  config = config == nil and {} or config
  require("repl.store").set_callbacks(config.callbacks)
  S.preferred = config.preferred or {}
  S.term_name = config.term_name or "term://repl"
  S.listed = config.listed ~= nil and config.listed or false

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
