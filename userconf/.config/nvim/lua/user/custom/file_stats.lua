local U = require("user.utils")
local F = require("user.functional")
local C = require("user.constants")

local function file_stats()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_line_count(buf)
  local size = U.convert(U.buffer_size(buf))

  local sections = {
    { tostring(buf), "Green" },
    { " ", "White" },
    { tostring(win), "Blue" },
    { " ", "White" },
  }
  local path = vim.fn.expand("%:p")
  local buftype = vim.bo[buf].buftype
  if F.contains(C.NOPATH_BUFTYPES, buftype) or path:sub(0, 1) ~= "/" then
    local name
    if buftype == "quickfix" then
      name = U.quickfix_title(win)
    else
      name = vim.api.nvim_buf_get_name(buf)
    end
    sections[#sections + 1] = { name, "Orange" }
  else
    local cwd, subpath = U.split_cwd_path(path)
    if cwd then
      sections[#sections + 1] = { cwd, "Yellow" }
    end
    sections[#sections + 1] = { subpath, "Pink" }
  end
  sections = F.concat(sections, {
    { " ", "White" },
    { string.format("%.0f%s", size.value, size.unit), size.color },
    { " ", "White" },
    { tostring(lines) .. "L", "White" },
  })
  vim.api.nvim_echo(sections, false, {})
end

local function filepath()
  print(vim.fn.expand("%:p"))
end

vim.keymap.set("n", "<space>pb", file_stats, { desc = "show information about buffer" })
vim.keymap.set("n", "<space>pp", filepath, { desc = "show current file path" })
