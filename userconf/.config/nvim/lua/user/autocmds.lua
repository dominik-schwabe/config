local F = require("user.functional")
local U = require("user.utils")

vim.api.nvim_create_augroup("user", {})

vim.filetype.add({
  extension = {
    pest = "pest",
    xj = "xj",
    xjl = "xjl",
    xdata = "xdata",
    xdatal = "xdatal",
    jon = "jon",
    cjon = "cjon",
    cjson = "cjson",
    kif = "lisp",
  },
})

local function set_window_options(opts)
  local bufnr = opts.buf
  local buftype = vim.bo[bufnr].buftype
  F.foreach(U.list_normal_windows(), function(win)
    if vim.api.nvim_win_get_buf(win) == bufnr then
      local wo = vim.wo[win]
      if buftype == "terminal" then
        wo.spell = false
        wo.number = false
        wo.relativenumber = false
        wo.signcolumn = "no"
      else
        wo.number = true
        wo.scrolloff = 8
        if buftype == "quickfix" then
          wo.signcolumn = "yes"
          wo.relativenumber = false
        else
          wo.signcolumn = "yes:2"
          wo.relativenumber = true
        end
      end
    end
  end)
end

vim.api.nvim_create_autocmd("TermOpen", {
  group = "UserTerm",
  callback = set_window_options,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = "user",
  callback = function(opts)
    local bo = vim.bo[opts.buf]
    if
      bo.buftype == "help"
      or F.contains({
        "qf",
        "help",
        "man",
        "notify",
        "lspinfo",
      }, bo.filetype)
    then
      bo.buflisted = false
      vim.keymap.set("n", "q", "<CMD>quit<CR>", { buffer = opts.buf, desc = "close the buffer" })
    end
    if bo.readonly then
      bo.modifiable = false
    end
    vim.opt.formatoptions:remove({ "c", "r", "o" })
    set_window_options(opts)
  end,
})

-- vim.api.nvim_create_autocmd("CmdWinEnter", {
--   group = "user",
--   callback = function(args)
--     vim.wo.number = false
--     vim.wo.relativenumber = false
--     vim.wo.signcolumn = "no"
--     vim.keymap.set({ "n", "i", "c" }, "<C-c>", "<ESC>:quit<CR>", { buffer = args.buf })
--     vim.keymap.set({ "n" }, "<ESC>", "<ESC>:quit<CR>", { buffer = args.buf })
--     vim.keymap.set({ "n" }, "<CR>", "<CR>", { buffer = args.buf })
--     vim.keymap.set({ "n", "i" }, "<C-h>", "<ESC>:quit<CR>", { buffer = args.buf })
--     vim.keymap.set({ "n", "i" }, "<C-j>", "<ESC>:quit<CR>", { buffer = args.buf })
--     vim.keymap.set({ "n", "i" }, "<C-k>", "<ESC>:quit<CR>", { buffer = args.buf })
--     vim.keymap.set({ "n", "i" }, "<C-l>", "<ESC>:quit<CR>", { buffer = args.buf })
--     vim.keymap.set({ "c" }, "<C-c>", "<CMD>quit<CR>", { buffer = args.buf })
--     vim.cmd("startinsert")
--   end,
-- })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = "user",
  callback = function()
    vim.hl.on_yank({ higroup = "YankHighlight", timeout = 400 })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = "user",
  command = "clearjumps",
})
