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
  local subpath
  if F.contains(NO_FILES, vim.bo[buf].buftype) then
    subpath = vim.api.nvim_buf_get_name(buf)
  else
    subpath = U.simplify_path(vim.fn.expand("%:p"))
    local root_path = vim.loop.cwd()
    if root_path:sub(-1) ~= "/" then
      root_path = root_path .. "/"
    end
    local was_removed
    subpath, was_removed = U.remove_path_prefix(subpath, root_path)
    if was_removed then
      root_path = U.remove_path_prefix(root_path, vim.env.HOME, "~/")
      sections = F.concat(sections, { { root_path, "Yellow" } })
    end
  end
  sections = F.concat(sections, {
    { subpath, "Pink" },
    { " ", "White" },
    { string.format("%.0f%s", size.value, size.unit), size.color },
    { " ", "White" },
    { tostring(lines), "White" },
  })
  vim.api.nvim_echo(sections, false, {})
end

local function filepath()
  print(vim.fn.expand("%:p"))
end

vim.keymap.set("n", "<C-g>", file_stats, { desc = "show information about buffer" })
vim.keymap.set("n", "<space>ag", filepath, { desc = "show current file path" })
