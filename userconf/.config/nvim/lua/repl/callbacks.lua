local window = require("repl.window")
local pp = require("repl.preprocess")

local M = {}

M.default_callbacks = {
  preprocess = pp.preprocess,
  format = function(lines)
    if #lines ~= 0 then
      lines[#lines] = lines[#lines] .. "\13"
    end
    return lines
  end,
  create_window = function()
    window.create_window(10, false)
  end,
  find_windows_with_repl = function(bufnr)
    return window.find_windows_with_repl(bufnr, true)
  end,
}

return M
