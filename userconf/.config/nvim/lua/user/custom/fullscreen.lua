local api = vim.api

local F = require("user.functional")

local FS

local function is_floating(win)
  return vim.api.nvim_win_get_config(win).zindex ~= nil
end

local function resize_fullscreen()
  local uis = api.nvim_list_uis()[1]
  api.nvim_win_set_width(FS.win, uis.width)
  api.nvim_win_set_height(FS.win, uis.height - 2)
end

local function fullscreen_off()
  F.foreach(FS.autocmd_ids, vim.api.nvim_del_autocmd)
  if api.nvim_win_is_valid(FS.win) then
    if api.nvim_win_is_valid(FS.origin_win) then
      if vim.api.nvim_win_get_buf(FS.origin_win) == FS.buf then
        local current_buf = vim.api.nvim_win_get_buf(FS.win)
        if current_buf ~= FS.buf then
          vim.api.nvim_win_set_buf(FS.origin_win, current_buf)
        end
        if vim.api.nvim_get_current_win() == FS.win then
          local row, col = unpack(api.nvim_win_get_cursor(FS.win))
          local topline = vim.fn.line("w0")
          api.nvim_win_set_cursor(FS.origin_win, { row, col })
          api.nvim_set_current_win(FS.origin_win)
          vim.fn.winrestview({ topline = topline })
        end
      end
    end
    api.nvim_win_close(FS.win, true)
  end
  FS = nil
end
local function get_normal_windows()
  return F.filter(vim.api.nvim_list_wins(), function(win)
    return not is_floating(win)
  end)
end

local function is_consistent()
  if not vim.api.nvim_win_is_valid(FS.win) or vim.api.nvim_win_get_buf(FS.win) ~= FS.buf then
    return false
  end
  local normal_windows = get_normal_windows()
  if #normal_windows ~= FS.state_len then
    return false
  end
  return F.all(normal_windows, function(window)
    return FS.state[window] == vim.api.nvim_win_get_buf(window)
  end)
end

local function fullscreen_toggle()
  if FS ~= nil then
    fullscreen_off()
  else
    if #get_normal_windows() <= 1 then
      vim.notify("already one window")
      return
    end
    local topline = vim.fn.line("w0")
    local origin_win = api.nvim_get_current_win()
    if is_floating(origin_win) then
      vim.notify("can not fullscreen floating window")
      return
    end
    local uis = api.nvim_list_uis()[1]
    local buf = api.nvim_win_get_buf(origin_win)
    local win = api.nvim_open_win(buf, true, {
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
      local row, col = unpack(api.nvim_win_get_cursor(origin_win))
      api.nvim_win_set_cursor(win, { row, col })
      local state = {}
      local normal_windows = get_normal_windows()
      F.foreach(normal_windows, function(window)
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
      FS.autocmd_ids[#FS.autocmd_ids + 1] = api.nvim_create_autocmd({
        "WinClosed",
        "WinEnter",
        "BufWinEnter",
        "WinNew",
      }, {
        callback = function()
          vim.schedule(function()
            if FS ~= nil and not is_consistent() then
              fullscreen_off()
            end
          end)
        end,
      })
      FS.autocmd_ids[#FS.autocmd_ids + 1] = api.nvim_create_autocmd("VimResized", {
        callback = resize_fullscreen,
      })
    end
  end
end

vim.keymap.set({ "n", "x", "i", "t" }, "<F24>", fullscreen_toggle, { desc = "toggle fullscreen" })
