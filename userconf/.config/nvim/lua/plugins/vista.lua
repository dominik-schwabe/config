local map = vim.api.nvim_set_keymap
local cmd = vim.cmd

local def_opt = {noremap = true, silent = true}

map("", "<F3>", "<ESC>:Vista!!<CR>", def_opt)
map("i", "<F3>", "<ESC>:Vista!!<CR>", def_opt)
