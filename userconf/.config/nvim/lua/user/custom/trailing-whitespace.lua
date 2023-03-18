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

local function trailing_highlight(buf, mode)
  if b[buf].disable_trailing then
    return
  end
  mode = mode or fn.mode()
  local win_id = api.nvim_get_current_win()
  local win_state = window_matches[win_id]
  if win_state ~= nil then
    if win_state.mode == mode then
      return
    else
      pcall(fn.matchdelete, win_state.id)
      window_matches[win_id] = nil
    end
  end
  if mode ~= nil then
    window_matches[win_id] = {
      id = fn.matchadd("TrailingWhitespace", trailing_patterns[mode]),
      mode = mode,
    }
  end
end

local function update_trailing_highlight(buf)
  local filetype = bo[buf].filetype
  b[buf].disable_trailing = vim.tbl_contains(whitespace_blacklist, filetype) or not bo[buf].modifiable
  trailing_highlight(buf)
end

vim.api.nvim_create_augroup("UserTrailingWhitespace", {})

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(opts)
    local buf = opts.buf
    b[opts.buf].is_big_buffer = config.is_big_buffer(buf)
    if not b[opts.buf].is_big_buffer then
      update_trailing_highlight(buf)
      vim.api.nvim_create_autocmd({ "InsertLeave" }, {
        group = "UserTrailingWhitespace",
        buffer = buf,
        callback = F.f(trailing_highlight, buf, "n"),
      })
      vim.api.nvim_create_autocmd({ "InsertEnter" }, {
        group = "UserTrailingWhitespace",
        buffer = buf,
        callback = F.f(trailing_highlight, buf, "i"),
      })
      vim.api.nvim_create_autocmd({ "BufEnter" }, {
        group = "UserTrailingWhitespace",
        buffer = buf,
        callback = F.f(trailing_highlight, buf),
      })
      vim.api.nvim_create_autocmd({ "FileType" }, {
        group = "UserTrailingWhitespace",
        buffer = buf,
        callback = F.f(update_trailing_highlight, buf),
      })
    end
  end,
})

vim.api.nvim_create_autocmd("OptionSet", {
  group = "UserTrailingWhitespace",
  pattern = "modifiable",
  callback = function(opts)
    if not b[opts.buf].is_big_buffer then
      update_trailing_highlight(opts.buf)
    end
  end,
})
