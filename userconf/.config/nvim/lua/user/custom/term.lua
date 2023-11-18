local config = require("user.config")

local function leave_term()
  vim.b.term_was_normal = true
  return "<C-\\><C-n>"
end

vim.keymap.set("t", "<C-e>", leave_term, { desc = "leave terminal mode", expr = true })

local function delete_term(args)
  vim.schedule(function()
    if vim.api.nvim_buf_is_loaded(args.buf) then
      vim.api.nvim_buf_delete(args.buf, { force = true })
    end
  end)
end

vim.api.nvim_create_augroup("UserTerm", {})
vim.api.nvim_create_autocmd("TermOpen", {
  group = "UserTerm",
  callback = function(args)
    vim.api.nvim_create_autocmd("BufEnter", {
      group = "UserTerm",
      buffer = args.buf,
      callback = function()
        if not vim.b.term_was_normal then
          vim.cmd("startinsert")
        end
      end,
    })
  end,
})

vim.api.nvim_create_autocmd("TermEnter", {
  group = "UserTerm",
  callback = function()
    vim.b.term_was_normal = false
  end,
})

vim.api.nvim_create_autocmd("TermClose", {
  group = "UserTerm",
  pattern = config.closable_terminals,
  callback = delete_term,
})
