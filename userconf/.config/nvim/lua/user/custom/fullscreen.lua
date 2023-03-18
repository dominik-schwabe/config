local api = vim.api
local fn = vim.fn

local F = require("user.functional")

local FLOAT_WIN
local WIN_ON_ENTER
local OLD_WIN_HIGHLIGHT
local BUFFER

local function resize_fullscreen()
  if FLOAT_WIN ~= nil and api.nvim_win_is_valid(FLOAT_WIN) then
    local uis = api.nvim_list_uis()[1]
    api.nvim_win_set_width(FLOAT_WIN, uis.width)
    api.nvim_win_set_height(FLOAT_WIN, uis.height - 2)
  end
end

local function fullscreen_off(goback)
  if FLOAT_WIN ~= nil and api.nvim_win_is_valid(FLOAT_WIN) then
    local float_win = FLOAT_WIN
    local win_on_enter = WIN_ON_ENTER
    local old_win_highlight = OLD_WIN_HIGHLIGHT
    WIN_ON_ENTER = nil
    FLOAT_WIN = nil
    OLD_WIN_HIGHLIGHT = nil
    vim.wo.winhighlight = old_win_highlight
    local topline = vim.fn.line("w0")
    local row, col = unpack(api.nvim_win_get_cursor(float_win))
    api.nvim_win_close(float_win, true)
    if api.nvim_win_is_valid(win_on_enter) then
      api.nvim_win_set_cursor(win_on_enter, { row, col })
      if goback then
        api.nvim_set_current_win(win_on_enter)
        vim.fn.winrestview({ topline = topline })
      end
    end
  end
end

local function all_windows()
  local winnr = fn.winnr("$")
  local winids = {}

  while winnr > 0 do
    winids[#winids + 1] = fn.win_getid(winnr)
    winnr = winnr - 1
  end

  return winids
end

local function fullscreen_toggle()
  if FLOAT_WIN ~= nil and api.nvim_win_is_valid(FLOAT_WIN) then
    fullscreen_off(true)
  else
    local nonfloat_windows = F.filter(all_windows(), function(winid)
      return api.nvim_win_get_config(winid).relative == ""
    end)
    if #nonfloat_windows <= 1 then
      vim.notify("already one window")
      return
    end
    local topline = vim.fn.line("w0")
    local window = api.nvim_get_current_win()
    if api.nvim_win_get_config(window).relative ~= "" then
      vim.notify("can not fullscreen floating window")
      return
    end
    WIN_ON_ENTER = window
    local uis = api.nvim_list_uis()[1]
    BUFFER = api.nvim_win_get_buf(WIN_ON_ENTER)
    FLOAT_WIN = api.nvim_open_win(BUFFER, true, {
      relative = "editor",
      row = 0,
      col = 0,
      height = uis.height - 2,
      width = uis.width,
      focusable = true,
      zindex = 5,
      border = "none",
    })
    if FLOAT_WIN ~= 0 then
      vim.fn.winrestview({ topline = topline })
      vim.wo.signcolumn = "yes"
      OLD_WIN_HIGHLIGHT = vim.wo.winhighlight
      vim.wo.winhighlight = "SignColumn:FullscreenMarker,NormalFloat:TermBackground"
      local row, col = unpack(api.nvim_win_get_cursor(WIN_ON_ENTER))
      api.nvim_win_set_cursor(FLOAT_WIN, { row, col })
    end
  end
end

api.nvim_create_augroup("UserFullscreen", {})
api.nvim_create_autocmd({ "WinEnter" }, {
  group = "UserFullscreen",
  callback = function(args)
    if args.file ~= "" and args.buf ~= BUFFER then
      fullscreen_off(false)
    end
  end,
})

api.nvim_create_autocmd({ "WinClosed" }, {
  group = "UserFullscreen",
  callback = function(args)
    if api.nvim_win_get_config(tonumber(args.file)).relative == "" then
      fullscreen_off(true)
    end
  end,
})

api.nvim_create_autocmd({ "BufAdd", "WinNew" }, {
  group = "UserFullscreen",
  callback = function()
    fullscreen_off(false)
  end,
})

api.nvim_create_autocmd("VimResized", {
  group = "UserFullscreen",
  callback = function()
    resize_fullscreen()
  end,
})

vim.keymap.set({ "n", "x", "i", "t" }, "<F24>", fullscreen_toggle, { desc = "toggle fullscreen" })
