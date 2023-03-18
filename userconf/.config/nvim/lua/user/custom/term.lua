local b = vim.b
local wo = vim.wo
local api = vim.api
local cmd = vim.cmd

local U = require("user.utils")
local F = require("user.functional")

local config = require("user.config")

local function leave_term()
  b.term_was_normal = true
  api.nvim_feedkeys(api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true), "t", true)
end

vim.keymap.set("t", "<C-e>", leave_term, { desc = "leave terminal mode" })

local function delete_term(args)
  if api.nvim_buf_is_loaded(args.buf) then
    api.nvim_buf_delete(args.buf, { force = true })
  end
end

local function set_term_options(args)
  local bufnr = args.buf
  local buftype = vim.bo[bufnr].buftype
  if buftype == "terminal" then
    wo.spell = false
    wo.number = false
    wo.relativenumber = false
    wo.signcolumn = "no"
  elseif not F.contains({ "quickfix", "nofile" }, buftype) and U.exists(api.nvim_buf_get_name(bufnr)) then
    wo.number = true
    wo.relativenumber = true
    wo.signcolumn = "yes:2"
  end
end

vim.api.nvim_create_augroup("UserTerm", {})
vim.api.nvim_create_autocmd("TermOpen", {
  group = "UserTerm",
  callback = function(args)
    set_term_options(args)
    vim.api.nvim_create_autocmd("BufEnter", {
      group = "UserTerm",
      buffer = args.buf,
      callback = function()
        if not b.term_was_normal then
          cmd("startinsert")
        end
      end,
    })
  end,
})

vim.api.nvim_create_autocmd("TermEnter", {
  group = "UserTerm",
  callback = function()
    b.term_was_normal = false
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = "UserTerm",
  callback = set_term_options,
})

vim.api.nvim_create_autocmd("TermClose", {
  group = "UserTerm",
  pattern = config.closable_terminals,
  callback = delete_term,
})
