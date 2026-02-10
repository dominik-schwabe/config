local M = {}

local popup

M.show = function(lines, opts)
  opts = opts or {}
  if not popup then
    popup = require("snacks").win({
      position = "float",
      fixbuf = true,
      show = false,
      col = -1,
      row = 0,
      width = 0.4,
      height = 0.4,
      border = "rounded",
      backdrop = false,
      minimal = true,
      enter = false,
      title_pos = "left",
    })
  end
  popup:show()
  popup:set_title(opts.title)
  vim.bo[popup.buf].filetype = opts.filetype
  vim.api.nvim_buf_set_lines(popup.buf, 0, -1, false, lines)
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = vim.api.nvim_create_augroup("preview", {}),
    once = true,
    callback = function()
      popup:close()
    end,
  })
end

return M
