local U = require("user.utils")
local F = require("user.functional")

vim.api.nvim_create_augroup("options", {})

vim.api.nvim_create_autocmd({ "BufReadPost", "FileType" }, {
  group = "options",
  callback = function(opts)
    local is_big_buffer = U.is_big_buffer_or_in_allowlist(opts.buf)
    vim.b[opts.buf].is_big_buffer = is_big_buffer
    if is_big_buffer then
      vim.cmd("syntax clear")
      vim.bo[opts.buf].syntax = "off"
      vim.bo[opts.buf].swapfile = false
      -- vim.bo[opts.buf].undolevels = -1
      F.load("illuminate.engine", function(illuminate)
        illuminate.stop_buf(opts.buf)
      end)
      F.load("colorizer", function(colorizer)
        colorizer.detach_from_buffer(opts.buf)
      end)
    end
  end,
})
