local fn = vim.fn
local api = vim.api

local function substitude_selection()
  api.nvim_feedkeys(":s/\\V\\(" .. fn.escape(fn.getreg("+"), "/\\") .. "\\)/\\1", "n", true)
end

vim.api.nvim_create_user_command("SubstitudeSelection", substitude_selection, {})
