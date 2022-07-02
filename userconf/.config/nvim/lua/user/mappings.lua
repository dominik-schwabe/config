vim.keymap.set("x", "p", '"_dP')
vim.keymap.set("x", "<space>P", "p")
vim.keymap.set({ "n", "x" }, "Q", "<CMD>qa<CR>")
vim.keymap.set({ "n", "x" }, "ö", "<CMD>noh<CR>")
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")
vim.keymap.set({ "n", "x", "t" }, "<C-h>", "<CMD>wincmd h<CR>")
vim.keymap.set({ "n", "x", "t" }, "<C-j>", "<CMD>wincmd j<CR>")
vim.keymap.set({ "n", "x", "t" }, "<C-k>", "<CMD>wincmd k<CR>")
vim.keymap.set({ "n", "x", "t" }, "<C-l>", "<CMD>wincmd l<CR>")
vim.keymap.set({ "n", "x" }, "<left>", "<CMD>wincmd H<CR>")
vim.keymap.set({ "n", "x" }, "<right>", "<CMD>wincmd L<CR>")
vim.keymap.set({ "n", "x" }, "<up>", "<CMD>wincmd K<CR>")
vim.keymap.set({ "n", "x" }, "<down>", "<CMD>wincmd J<CR>")
vim.keymap.set("n", "db", "dvb")
vim.keymap.set("n", "dB", "dvB")
vim.keymap.set("n", "cb", "cvb")
vim.keymap.set("n", "cB", "cvB")
vim.keymap.set("n", "<C-g>", "2<C-g>")
