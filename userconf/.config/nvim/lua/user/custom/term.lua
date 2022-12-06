local b = vim.b
local api = vim.api
local cmd = vim.cmd

local config = require("user.config")

local function leave_term()
  b.term_was_normal = true
  api.nvim_feedkeys(api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true), "t", true)
end

vim.keymap.set("t", "<C-e>", leave_term)

local function delete_term(args)
  if api.nvim_buf_is_loaded(args.buf) then
    api.nvim_buf_delete(args.buf, { force = true })
  end
end

local function enter_term()
  if vim.o.buftype == "terminal" and not b.term_was_normal then
    cmd("startinsert")
  end
end

vim.api.nvim_create_autocmd("TermOpen", {
  command = "setlocal nospell nonumber norelativenumber signcolumn=no filetype=term",
})
vim.api.nvim_create_autocmd("TermEnter", {
  callback = function()
    b.term_was_normal = false
  end,
})
vim.api.nvim_create_autocmd("BufEnter", {
  callback = enter_term,
})
vim.api.nvim_create_autocmd("TermClose", {
  pattern = config.closable_terminals,
  callback = delete_term,
})
