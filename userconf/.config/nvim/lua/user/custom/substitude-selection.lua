local function substitude_selection()
  vim.api.nvim_feedkeys(":s/\\V\\(" .. vim.fn.escape(vim.fn.getreg("+"), "/\\") .. "\\)/\\1", "n", true)
end

vim.api.nvim_create_user_command("SubstitudeSelection", substitude_selection, {})
