local U = require("user.utils")
local F = require("user.functional")

local NO_FILES = {
  "nofile",
  "quickfix",
  "terminal",
  "prompt",
}

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
  if F.contains(NO_FILES, vim.bo[buf].buftype) or path:sub(0, 1) ~= "/" then
    local name = vim.api.nvim_buf_get_name(buf)
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

vim.keymap.set("n", "<C-g>", file_stats, { desc = "show information about buffer" })
vim.keymap.set("n", "<space>ag", filepath, { desc = "show current file path" })
