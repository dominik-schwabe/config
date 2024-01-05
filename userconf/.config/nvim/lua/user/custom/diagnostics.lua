local F = require("user.functional")
local C = require("user.constants")
local U = require("user.utils")

local function show_diagnostics(only_buffer)
  local name = "Diagnostics "
  local diagnostics
  if only_buffer then
    local buf = U.last_regular_buffer()
    diagnostics = vim.diagnostic.get(buf)
    name = name .. buf .. " " .. vim.api.nvim_buf_get_name(buf)
  else
    local cwd = U.cwd()
    local buffers = U.list_buffers({ mru = true, buftype = C.PATH_BUFTYPES, unloaded = true, unlisted = true })
    buffers = F.filter(buffers, function(buf)
      return vim.startswith(U.buffer_path(buf), cwd)
    end)
    diagnostics = F.map(buffers, function(buf)
      return vim.diagnostic.get(buf)
    end)
    diagnostics = F.concat(unpack(diagnostics))
    name = name .. "Workspace"
  end
  diagnostics = vim.diagnostic.toqflist(diagnostics)
  U.quickfix(diagnostics, name)
end

vim.keymap.set("n", "<space>d", F.f(show_diagnostics)(true), { desc = "show buffer diagnostics in quickfix" })
vim.keymap.set("n", "<space>w", function()
  show_diagnostics(false)
end, { desc = "show workspace diagnostics in quickfix" })
