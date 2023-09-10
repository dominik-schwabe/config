local U = require("user.utils")
local F = require("user.functional")

vim.api.nvim_create_augroup("options", {})

vim.api.nvim_create_autocmd({ "BufReadPost", "FileType" }, {
  group = "options",
  callback = function(opts)
    local is_big_buffer = U.is_in_big_buffer_allowlist(opts.buf)
    vim.b[opts.buf].is_big_buffer = is_big_buffer
    if is_big_buffer then
      vim.bo[opts.buf].syntax = "off"
      vim.opt_local.swapfile = false
      F.load("illuminate.engine", function(illuminate)
        illuminate.stop_buf(opts.buf)
      end)
    end
  end,
})
