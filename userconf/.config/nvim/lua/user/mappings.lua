vim.keymap.set({ "n", "x" }, "Q", "<CMD>qa<CR>", { desc = "quit neovim" })
vim.keymap.set({ "n", "x" }, "ö", "<CMD>noh<CR>", { desc = "clear selection" })
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
vim.keymap.set({ "n" }, "<space>i", "<CMD>Inspect<CR>", { desc = "inspect current element" })

local function movement(key)
  return function()
    local count = vim.v.count
    if count == 0 then
      vim.api.nvim_feedkeys("g" .. key, "n", false)
    else
      vim.cmd.normal({ "m'", bang = true })
      vim.api.nvim_feedkeys(tostring(count) .. key, "n", false)
    end
  end
end

vim.keymap.set("n", "k", movement("k"), { silent = true })
vim.keymap.set("n", "j", movement("j"), { silent = true })
vim.keymap.set("n", "$", "g$", { silent = true })
vim.keymap.set("n", "0", "g0", { silent = true })
vim.keymap.set("n", "<space>cw", function()
  vim.cmd("cd %:p:h")
end, { desc = "change directory to current file" })
