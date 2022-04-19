local def_opt = { noremap = true, silent = true }

vim.keymap.set("", "<F3>", "<ESC>:Vista!!<CR>", def_opt)
vim.keymap.set("i", "<F3>", "<ESC>:Vista!!<CR>", def_opt)
