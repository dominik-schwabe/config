local FLOAT_WIN
local WIN_ON_ENTER
local OLD_WIN_HIGHLIGHT

local function fullscreen_off()
  if FLOAT_WIN ~= nil and vim.api.nvim_win_is_valid(FLOAT_WIN) then
    vim.wo.winhighlight = OLD_WIN_HIGHLIGHT
    local topline = vim.fn.line("w0")
    local row, col = unpack(vim.api.nvim_win_get_cursor(FLOAT_WIN))
    vim.api.nvim_set_current_win(FLOAT_WIN)
    vim.cmd("q")
    if vim.api.nvim_win_is_valid(WIN_ON_ENTER) then
      vim.api.nvim_win_set_cursor(WIN_ON_ENTER, { row, col })
      vim.api.nvim_set_current_win(WIN_ON_ENTER)
      vim.fn.winrestview({ topline = topline })
    end
    WIN_ON_ENTER = nil
    FLOAT_WIN = nil
    OLD_WIN_HIGHLIGHT = nil
  end
end

local function fullscreen_toggle()
  if FLOAT_WIN ~= nil and vim.api.nvim_win_is_valid(FLOAT_WIN) then
    fullscreen_off()
  else
    local topline = vim.fn.line("w0")
    WIN_ON_ENTER = vim.api.nvim_get_current_win()
    FLOAT_WIN = vim.api.nvim_open_win(0, true, {
      relative = "editor",
      row = 0,
      col = 0,
      height = 1000,
      width = 1000,
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

vim.api.nvim_create_autocmd("BufLeave", { callback = fullscreen_off })

vim.keymap.set({ "n", "x", "i", "t" }, "<F12>", fullscreen_toggle)
