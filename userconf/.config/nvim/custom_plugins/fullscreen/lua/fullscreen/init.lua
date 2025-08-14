local U = require("fullscreen.utils")

local M = {}

local FS

local function resize_fullscreen()
  local uis = vim.api.nvim_list_uis()[1]
  vim.api.nvim_win_set_width(FS.win, uis.width)
  vim.api.nvim_win_set_height(FS.win, uis.height - 2)
end

local function fullscreen_off()
  vim.iter(FS.autocmd_ids):each(vim.api.nvim_del_autocmd)
  if vim.api.nvim_win_is_valid(FS.win) then
    if vim.api.nvim_win_is_valid(FS.origin_win) then
      if vim.api.nvim_win_get_buf(FS.origin_win) == FS.buf then
        local current_buf = vim.api.nvim_win_get_buf(FS.win)
        if current_buf ~= FS.buf then
          vim.api.nvim_win_set_buf(FS.origin_win, current_buf)
        end
        if vim.api.nvim_get_current_win() == FS.win then
          local row, col = unpack(vim.api.nvim_win_get_cursor(FS.win))
          local topline = vim.fn.line("w0")
          vim.api.nvim_win_set_cursor(FS.origin_win, { row, col })
          vim.api.nvim_set_current_win(FS.origin_win)
          vim.fn.winrestview({ topline = topline })
        end
      end
    end
    vim.api.nvim_win_close(FS.win, true)
  end
  FS = nil
end

local function is_consistent()
  if
    not vim.api.nvim_win_is_valid(FS.win)
    or vim.api.nvim_win_get_buf(FS.win) ~= FS.buf
    or not U.is_floating(vim.api.nvim_get_current_win())
  then
    return false
  end
  local normal_windows = U.list_normal_windows()
  if #normal_windows ~= FS.state_len then
    return false
  end
  return vim.iter(normal_windows):all(function(window)
    return FS.state[window] == vim.api.nvim_win_get_buf(window)
  end)
end

function M.toggle_fullscreen()
  if FS ~= nil then
    fullscreen_off()
  else
    if #U.list_normal_windows() <= 1 then
      vim.notify("already one window")
      return
    end
    local topline = vim.fn.line("w0")
    local origin_win = vim.api.nvim_get_current_win()
    if U.is_floating(origin_win) then
      vim.notify("can not fullscreen floating window")
      return
    end
    local uis = vim.api.nvim_list_uis()[1]
    local buf = vim.api.nvim_win_get_buf(origin_win)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      row = 0,
      col = 0,
      height = uis.height - 2,
      width = uis.width,
      focusable = true,
      zindex = 5,
      border = "none",
    })
    if win ~= 0 then
      vim.fn.winrestview({ topline = topline })
      local row, col = unpack(vim.api.nvim_win_get_cursor(origin_win))
      vim.api.nvim_win_set_cursor(win, { row, col })
      local state = {}
      local normal_windows = U.list_normal_windows()
      vim.iter(normal_windows):each(function(window)
        state[window] = vim.api.nvim_win_get_buf(window)
      end)
      FS = {
        origin_win = origin_win,
        win = win,
        buf = buf,
        state_len = #normal_windows,
        state = state,
      }
      FS.autocmd_ids = {}
      FS.autocmd_ids[#FS.autocmd_ids + 1] = vim.api.nvim_create_autocmd({
        "WinClosed",
        "WinEnter",
        "BufWinEnter",
        "WinNew",
      }, {
        callback = vim.schedule_wrap(function()
          if FS ~= nil and not is_consistent() then
            fullscreen_off()
          end
        end),
      })
      FS.autocmd_ids[#FS.autocmd_ids + 1] = vim.api.nvim_create_autocmd("VimResized", {
        callback = resize_fullscreen,
      })
    end
  end
end

function M.setup(opts)
  vim.api.nvim_create_user_command("ToggleFullscreen", M.toggle_fullscreen, {})
end

return M
