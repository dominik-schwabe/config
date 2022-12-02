local FLOAT_WIN
local WIN_ON_ENTER
local OLD_WIN_HIGHLIGHT
local BUFFER

local function resize_fullscreen()
  if FLOAT_WIN ~= nil and vim.api.nvim_win_is_valid(FLOAT_WIN) then
    local uis = vim.api.nvim_list_uis()[1]
    vim.api.nvim_win_set_width(FLOAT_WIN, uis.width)
    vim.api.nvim_win_set_height(FLOAT_WIN, uis.height - 2)
  end
end

local function fullscreen_off(goback)
  if FLOAT_WIN ~= nil and vim.api.nvim_win_is_valid(FLOAT_WIN) then
    local float_win = FLOAT_WIN
    local win_on_enter = WIN_ON_ENTER
    local old_win_highlight = OLD_WIN_HIGHLIGHT
    WIN_ON_ENTER = nil
    FLOAT_WIN = nil
    OLD_WIN_HIGHLIGHT = nil
    vim.wo.winhighlight = old_win_highlight
    local topline = vim.fn.line("w0")
    local row, col = unpack(vim.api.nvim_win_get_cursor(float_win))
    vim.api.nvim_win_close(float_win, true)
    if vim.api.nvim_win_is_valid(win_on_enter) then
      vim.api.nvim_win_set_cursor(win_on_enter, { row, col })
      if goback then
        vim.api.nvim_set_current_win(win_on_enter)
        vim.fn.winrestview({ topline = topline })
      end
    end
  end
end

local function fullscreen_toggle()
  if FLOAT_WIN ~= nil and vim.api.nvim_win_is_valid(FLOAT_WIN) then
    fullscreen_off(true)
  else
    local topline = vim.fn.line("w0")
    WIN_ON_ENTER = vim.api.nvim_get_current_win()
    local uis = vim.api.nvim_list_uis()[1]
    BUFFER = vim.api.nvim_win_get_buf(WIN_ON_ENTER)
    FLOAT_WIN = vim.api.nvim_open_win(BUFFER, true, {
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
      local row, col = unpack(vim.api.nvim_win_get_cursor(WIN_ON_ENTER))
      vim.api.nvim_win_set_cursor(FLOAT_WIN, { row, col })
    end
  end
end

vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
  callback = function(args)
    if args.buf == BUFFER then
      fullscreen_off(false)
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    resize_fullscreen()
  end,
})

vim.keymap.set({ "n", "x", "i", "t" }, "<F12>", fullscreen_toggle)
