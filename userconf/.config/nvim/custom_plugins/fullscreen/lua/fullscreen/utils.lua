local F = require("fullscreen.functional")

local M = {}

function M.is_floating(win)
  return vim.api.nvim_win_get_config(win).zindex ~= nil
end

function M.list_normal_windows()
  return F.filter(vim.api.nvim_list_wins(), function(win)
    return not M.is_floating(win)
  end)
end

return M
