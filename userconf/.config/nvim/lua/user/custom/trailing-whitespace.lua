local config = require("user.config")

local F = require("user.functional")

local whitespace_blacklist = config.whitespace_blacklist

local trailing_patterns = {
  n = [[\(\s\|\r\)\+$]],
  i = [[\(\s\|\r\)\+\%#\@<!$]],
}

local function trailing_highlight(mode)
  mode = mode or vim.fn.mode()
  local current_window = vim.api.nvim_get_current_win()
  F.foreach(vim.api.nvim_list_wins(), function(window)
    local new_win_mode = nil
    local buf = vim.api.nvim_win_get_buf(window)
    if window == current_window and not vim.b[buf].disable_trailing then
      new_win_mode = mode
    end
    local trailing_state = vim.w[window].trailing_state or {}
    if trailing_state.mode ~= new_win_mode then
      if trailing_state.id ~= nil then
        vim.fn.matchdelete(trailing_state.id, window)
      end
      local new_win_state = nil
      local pattern = trailing_patterns[new_win_mode]
      if pattern ~= nil then
        new_win_state = {
          id = vim.fn.matchadd("TrailingWhitespace", pattern, 10, -1, { window = window }),
          mode = new_win_mode,
        }
      end
      vim.w[window].trailing_state = new_win_state
    end
  end)
end

local function update_trailing_highlight(opts)
  local buf = opts.buf
  local filetype = vim.bo[buf].filetype
  vim.b[buf].disable_trailing = vim.b[buf].is_big_buffer
    or F.contains(whitespace_blacklist, filetype)
    or not vim.bo[buf].modifiable
  trailing_highlight()
end

vim.api.nvim_create_augroup("UserTrailingWhitespace", {})

vim.api.nvim_create_autocmd({ "BufWrite", "BufEnter", "WinEnter", "FileType" }, {
  group = "UserTrailingWhitespace",
  callback = update_trailing_highlight,
})

vim.api.nvim_create_autocmd("OptionSet", {
  group = "UserTrailingWhitespace",
  pattern = "modifiable",
  callback = update_trailing_highlight,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = "UserTrailingWhitespace",
  callback = F.f(trailing_highlight, nil),
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  group = "UserTrailingWhitespace",
  callback = F.f(trailing_highlight, "n"),
})

vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  group = "UserTrailingWhitespace",
  callback = F.f(trailing_highlight, "i"),
})
