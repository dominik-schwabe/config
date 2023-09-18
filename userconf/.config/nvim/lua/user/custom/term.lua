local U = require("user.utils")
local F = require("user.functional")

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

local function set_term_options(args)
  local bufnr = args.buf
  local buftype = vim.bo[bufnr].buftype
  F.foreach(vim.api.nvim_list_wins(), function(win)
    if vim.api.nvim_win_get_buf(win) == bufnr then
      local wo = vim.wo[win]
      if buftype == "terminal" then
        wo.spell = false
        wo.number = false
        wo.relativenumber = false
        wo.signcolumn = "no"
      elseif buftype == "quickfix" then
        wo.signcolumn = "yes"
        wo.number = true
        wo.relativenumber = false
      elseif buftype ~= "nofile" and U.exists(vim.api.nvim_buf_get_name(bufnr)) then
        wo.signcolumn = "yes:2"
        wo.number = true
        wo.relativenumber = true
      end
    end
  end)
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

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = "UserTerm",
  callback = set_term_options,
})

vim.api.nvim_create_autocmd("TermClose", {
  group = "UserTerm",
  pattern = config.closable_terminals,
  callback = delete_term,
})
