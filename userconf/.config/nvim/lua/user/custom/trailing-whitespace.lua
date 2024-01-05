local F = require("user.functional")
local C = require("user.constants")

local trailing_patterns = {
  n = [[\(\s\|\r\)\+$]],
  i = [[\(\s\|\r\)\+\%#\@<!$]],
}

local filetype_denylist = { "markdown" }

local trailing_highlight = F.defer(function(opts)
  local mode = opts.mode or vim.fn.mode()
  local current_window = vim.api.nvim_get_current_win()
  F.foreach(vim.api.nvim_list_wins(), function(window)
    local new_win_mode = nil
    local buf = vim.api.nvim_win_get_buf(window)
    local bo = vim.bo[buf]
    if window == current_window then
      local disable_trailing = vim.b[buf].is_big_buffer
        or not F.contains(C.FILE_BUFTYPE, bo.buftype)
        or not bo.modifiable
        or F.contains(filetype_denylist, bo.filetype)
      if not disable_trailing then
        new_win_mode = mode
      end
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
end, 30)

vim.api.nvim_create_augroup("UserTrailingWhitespace", {})

vim.api.nvim_create_autocmd({ "OptionSet" }, {
  group = "UserTrailingWhitespace",
  pattern = { "buftype", "modifiable", "filetype" },
  callback = function(opts)
    if vim.v.option_new ~= vim.v.option_old then
      trailing_highlight(opts)
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = "UserTrailingWhitespace",
  callback = trailing_highlight,
})

local trailing_highlight_cb = F.f(trailing_highlight)

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  group = "UserTrailingWhitespace",
  callback = trailing_highlight_cb({ mode = "n" }),
})

vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  group = "UserTrailingWhitespace",
  callback = trailing_highlight_cb({ mode = "i" }),
})
