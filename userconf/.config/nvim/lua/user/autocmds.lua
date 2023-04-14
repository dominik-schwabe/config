vim.api.nvim_create_augroup("user", {})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = "user",
  callback = function(opts)
    local bo = vim.bo[opts.buf]
    if bo.buftype == "help" then
      vim.keymap.set("n", "q", "<CMD>quit<CR>", { buffer = opts.buf, desc = "close the buffer" })
    end
    if bo.readonly then
      bo.modifiable = false
    end
    vim.opt.formatoptions:remove({ "c", "r", "o" })
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
    vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 400 })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = "user",
  command = "clearjumps",
})
