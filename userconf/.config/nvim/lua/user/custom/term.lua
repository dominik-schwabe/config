local U = require("user.utils")
local F = require("user.functional")

local config = require("user.config")

local function leave_term()
  vim.b.term_was_normal = true
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true), "t", true)
end

vim.keymap.set("t", "<C-e>", leave_term, { desc = "leave terminal mode" })

local function delete_term(args)
  if vim.api.nvim_buf_is_loaded(args.buf) then
    vim.api.nvim_buf_delete(args.buf, { force = true })
  end
end

local function set_term_options(args)
  local bufnr = args.buf
  local buftype = vim.bo[bufnr].buftype
  if buftype == "terminal" then
    vim.wo.spell = false
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
  elseif not F.contains({ "quickfix", "nofile" }, buftype) and U.exists(vim.api.nvim_buf_get_name(bufnr)) then
    vim.wo.number = true
    vim.wo.relativenumber = true
    vim.wo.signcolumn = "yes:2"
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

vim.api.nvim_create_autocmd("BufEnter", {
  group = "UserTerm",
  callback = set_term_options,
})

vim.api.nvim_create_autocmd("TermClose", {
  group = "UserTerm",
  pattern = config.closable_terminals,
  callback = delete_term,
})
