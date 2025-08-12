local F = require("user.functional")
local C = require("user.constants")

vim.keymap.set({ "n" }, "<leader>x", "<CMD>:.lua<CR>", { desc = "interpret the current lua line" })
vim.keymap.set({ "n", "x" }, "Q", "<CMD>qa<CR>", { desc = "quit neovim" })
vim.keymap.set({ "n", "x" }, "<C-e>", "<CMD>noh|diffupdate<CR>", { desc = "clear selection" })
vim.keymap.set("x", "<", "<gv", { desc = "decrement indentation" })
vim.keymap.set("x", ">", ">gv", { desc = "increment indentation" })
vim.keymap.set({ "n", "x", "t" }, "<C-h>", "<CMD>wincmd h<CR>", { desc = "move to left window" })
vim.keymap.set({ "n", "x", "t" }, "<C-j>", "<CMD>wincmd j<CR>", { desc = "move to window below" })
vim.keymap.set({ "n", "x", "t" }, "<C-k>", "<CMD>wincmd k<CR>", { desc = "move to window above" })
vim.keymap.set({ "n", "x", "t" }, "<C-l>", "<CMD>wincmd l<CR>", { desc = "move to right window" })
vim.keymap.set({ "i" }, "<C-h>", "<ESC>:wincmd h<CR>", { desc = "move to left window" })
vim.keymap.set({ "i" }, "<C-j>", "<ESC>:wincmd j<CR>", { desc = "move to window below" })
vim.keymap.set({ "i" }, "<C-k>", "<ESC>:wincmd k<CR>", { desc = "move to window above" })
vim.keymap.set({ "i" }, "<C-l>", "<ESC>:wincmd l<CR>", { desc = "move to right window" })
vim.keymap.set({ "n", "x" }, "<left>", "<CMD>wincmd H<CR>", { desc = "swap with left window" })
vim.keymap.set({ "n", "x" }, "<right>", "<CMD>wincmd L<CR>", { desc = "swap with window below" })
vim.keymap.set({ "n", "x" }, "<up>", "<CMD>wincmd K<CR>", { desc = "swap with window above" })
vim.keymap.set({ "n", "x" }, "<down>", "<CMD>wincmd J<CR>", { desc = "swap with right window" })
vim.keymap.set("n", "db", "dvb", { desc = "delete word backwards" })
vim.keymap.set("n", "dB", "dvB", { desc = "delete word backwards with punctuation" })
vim.keymap.set("n", "cb", "cvb", { desc = "change word backwards" })
vim.keymap.set("n", "cB", "cvB", { desc = "change word backwards with punctuation" })
vim.keymap.set("n", "yb", "yvb", { desc = "yank word backwards" })
vim.keymap.set("n", "yB", "yvB", { desc = "yank word backwards with punctuation" })
vim.keymap.set({ "n", "x" }, "gw", "<CMD>write<CR>", { desc = "write buffer changes" })
vim.keymap.set({ "n", "x" }, "gq", "gw", { desc = "break line" })
vim.keymap.set({ "n" }, "gqq", "gwl", { desc = "break line" })
vim.keymap.set({ "n", "x" }, "<space>tw", "<CMD>set wrap!<CR>", { desc = "toggle wrap" })
vim.keymap.set({ "n", "x" }, "<space>tl", "<CMD>set relativenumber!<CR>", { desc = "toggle relativenumber" })
vim.keymap.set({ "n" }, "<space>i", "<CMD>Inspect<CR>", { desc = "inspect current element" })
vim.keymap.set("n", "<space>cw", function()
  if F.contains(C.PATH_BUFTYPES, vim.bo.buftype) then
    vim.cmd("cd %:p:h")
    vim.notify("new cwd: " .. vim.fn.getcwd())
  else
    vim.notify("no file", vim.log.levels.ERROR)
  end
end, { desc = "change directory to current file" })

local function movement(key)
  return function()
    if vim.v.count == 0 then
      return "g" .. key
    else
      local win = vim.api.nvim_get_current_win()
      local buf = vim.api.nvim_win_get_buf(win)
      local l, c = unpack(vim.api.nvim_win_get_cursor(win))
      vim.api.nvim_buf_set_mark(buf, "'", l, c, {})
      return key
    end
  end
end

vim.keymap.set({ "n", "x" }, "k", movement("k"), { silent = true, expr = true })
vim.keymap.set({ "n", "x" }, "j", movement("j"), { silent = true, expr = true })
vim.keymap.set("n", "<", "<<")
vim.keymap.set("n", ">", ">>")
