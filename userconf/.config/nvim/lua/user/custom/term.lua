local b = vim.b
local wo = vim.wo
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

local function set_term_options()
  wo.spell = false
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
end

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(args)
    set_term_options()
    vim.api.nvim_create_autocmd("BufEnter", {
      buffer = args.buf,
      callback = function()
        set_term_options()
        if not b.term_was_normal then
          cmd("startinsert")
        end
      end,
    })
  end,
})

vim.api.nvim_create_autocmd("TermClose", {
  pattern = config.closable_terminals,
  callback = delete_term,
})
