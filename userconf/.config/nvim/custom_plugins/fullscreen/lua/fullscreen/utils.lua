local M = {}

function M.is_floating(win)
  return vim.api.nvim_win_get_config(win).zindex ~= nil
end

function M.list_normal_windows()
  return vim
    .iter(vim.api.nvim_list_wins())
    :filter(function(win)
      return not M.is_floating(win)
    end)
    :totable()
end

return M
