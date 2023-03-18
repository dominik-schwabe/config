local U = require("user.utils")
local F = require("user.functional")

vim.api.nvim_create_augroup("options", {})

vim.api.nvim_create_autocmd({ "BufReadPost", "FileType" }, {
  group = "options",
  callback = function(opts)
    if U.is_big_buffer_whitelisted(opts.buf) then
      vim.bo[opts.buf].syntax = "off"
      vim.opt_local.swapfile = false
      F.load("illuminate.engine", function(illuminate)
        illuminate.stop_buf(opts.buf)
      end)
      vim.api.nvim_create_autocmd({ "LspAttach" }, {
        buffer = opts.buf,
        callback = function(args)
          vim.schedule(function()
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if F.contains(client.attached_buffers, opts.buf) then
              vim.lsp.buf_detach_client(opts.buf, args.data.client_id)
            end
          end)
        end,
      })
    end
  end,
})
