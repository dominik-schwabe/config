local b = vim.b
local bo = vim.bo
local fn = vim.fn
local api = vim.api

local config = require("user.config")

local F = require("user.functional")

local whitespace_blacklist = config.whitespace_blacklist
local window_matches = {}

local trailing_patterns = {
  n = [[\(\s\|\r\)\+$]],
  i = [[\(\s\|\r\)\+\%#\@<!$]],
}

local function trailing_highlight(mode)
  if b.disable_trailing then
    mode = nil
  elseif mode == "auto" then
    mode = fn.mode()
  end
  local win_id = api.nvim_get_current_win()
  local win_state = window_matches[win_id]
  if win_state == nil and mode == nil then
    return
  end
  if win_state ~= nil then
    if win_state.mode == mode then
      return
    else
      pcall(fn.matchdelete, win_state.id)
      window_matches[win_id] = nil
    end
  end
  if mode ~= nil then
    local pattern = trailing_patterns[mode]
    local match_id = fn.matchadd("TrailingWhitespace", pattern)
    window_matches[win_id] = { id = match_id, mode = mode }
  end
end

local function update_trailing_highlight(args)
  local filetype = args.match
  if filetype == "" then
    filetype = bo.filetype
  end
  b.disable_trailing = F.contains(whitespace_blacklist, filetype) or not bo.modifiable
  trailing_highlight("auto")
end

vim.api.nvim_create_augroup("UserTrailingWhitespace", {})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = "UserTrailingWhitespace",
  callback = F.f(trailing_highlight, "n")
})
vim.api.nvim_create_autocmd("InsertEnter", {
  group = "UserTrailingWhitespace",
  callback = F.f(trailing_highlight, "i")
})
vim.api.nvim_create_autocmd("BufEnter", {
  group = "UserTrailingWhitespace",
  callback = F.f(trailing_highlight, "auto")
})
vim.api.nvim_create_autocmd("TermOpen", {
  group = "UserTrailingWhitespace",
  callback = update_trailing_highlight,
})
vim.api.nvim_create_autocmd("FileType", {
  group = "UserTrailingWhitespace",
  callback = update_trailing_highlight,
})
vim.api.nvim_create_autocmd("OptionSet", {
  group = "UserTrailingWhitespace",
  pattern = "modifiable",
  callback = update_trailing_highlight,
})
