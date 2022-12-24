local api = vim.api
local bo = vim.bo

local unpack = unpack

local utils = require("user.utils")
local config = require("user.config")

local F = require("user.functional")
local U = require("repl.utils")

local function num_leading_spaces(str)
  local first_char = str:find("[^ ]")
  return first_char and first_char - 1 or #str
end

local function insert_brackets(open, close, same_line)
  local row, col = unpack(api.nvim_win_get_cursor(0))
  if same_line then
    api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { open .. close })
    api.nvim_win_set_cursor(0, { row, col + 1 })
  else
    local prev_line = api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local num_tabs = math.floor(num_leading_spaces(U.replace_tab(prev_line)) / bo.shiftwidth)
    local lines = { open, utils.get_shifts(num_tabs + 1), utils.get_shifts(num_tabs) .. close }
    api.nvim_buf_set_text(0, row - 1, col, row - 1, col, lines)
    local line = api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    api.nvim_win_set_cursor(0, { row + 1, #line })
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

vim.keymap.set("i", "<C-e>", F.f(insert_brackets, "(", ")", true), {})

for _, quote in ipairs(config.quotes) do
  vim.keymap.set("i", "<C-S>" .. quote, F.f(insert_brackets, quote, quote, true), {})
  vim.keymap.set("i", "<C-S><C-" .. quote .. ">", F.f(insert_brackets, quote, quote, true), {})
end
