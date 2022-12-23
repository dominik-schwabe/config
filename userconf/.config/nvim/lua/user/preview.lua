local Popup = require("nui.popup")

local F = require("user.functional")

local M = {}

local size = {
  width = "50%",
  height = 1,
}
local position = {
  row = 0,
  col = "100%",
}

local popup

M.show = function(lines, opts)
  opts = opts or {}
  local title = opts.title
  local buf_callback = opts.buf_callback
  if not popup then
    popup = Popup({
      enter = false,
      relative = "editor",
      focusable = false,
      border = {
        style = "rounded",
        text = {},
      },
      position = position,
      size = size,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      callback = function()
        popup:hide()
      end,
    })
    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        popup:hide()
        popup:update_layout({ position = position })
      end,
    })
    popup:mount()
  end
  local limit = math.min(#lines, 15)
  lines = F.limit(lines, limit)
  size = {
    width = "50%",
    height = limit,
  }
  popup:update_layout({ size = size })
  popup.border:set_text("top", title, "left")
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(popup.bufnr, "filetype", opts.filetype or "")
  if buf_callback then
    buf_callback(popup.bufnr)
  end
  popup:show()
end

return M
