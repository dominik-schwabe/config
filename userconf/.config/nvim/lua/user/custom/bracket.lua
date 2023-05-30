local config = require("user.config")

local F = require("user.functional")
local U = require("user.utils")

local function num_leading_spaces(str)
  local first_char = str:find("[^ ]")
  return first_char and first_char - 1 or #str
end

local function insert_brackets(open, close, same_line)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  if same_line then
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { open .. close })
    vim.api.nvim_win_set_cursor(0, { row, col + 1 })
  else
    local prev_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local num_tabs = math.floor(num_leading_spaces(U.replace_tab(prev_line)) / vim.bo.shiftwidth)
    local lines = { open, U.get_shifts(num_tabs + 1), U.get_shifts(num_tabs) .. close }
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, lines)
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    vim.api.nvim_win_set_cursor(0, { row + 1, #line })
  end
end

for _, brackets in ipairs(config.brackets) do
  local open, close = unpack(brackets)
  vim.keymap.set("i", "<C-S>" .. open, F.f(insert_brackets, open, close, true), {})
  vim.keymap.set("i", "<C-S><C-" .. open .. ">", F.f(insert_brackets, open, close, true), {})
  vim.keymap.set("i", "<C-S>" .. close, F.f(insert_brackets, open, close, false), {})
  if close == "}" then
    vim.keymap.set("i", "<C-S><C-]>", F.f(insert_brackets, open, close, false), {})
  elseif close ~= "]" then
    vim.keymap.set("i", "<C-S><C-" .. close .. ">", F.f(insert_brackets, open, close, false), {})
  end
end

for _, quote in ipairs(config.quotes) do
  vim.keymap.set("i", "<C-S>" .. quote, F.f(insert_brackets, quote, quote, true), {})
  vim.keymap.set("i", "<C-S><C-" .. quote .. ">", F.f(insert_brackets, quote, quote, true), {})
end
