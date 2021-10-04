local g = vim.g
local map = vim.api.nvim_set_keymap

local def_opt = {noremap = true, silent = true}

g.zoomwintab_remap = 0

map("", "<F12>", "<cmd>ZoomWinTabToggle<cr>", def_opt)
map("i", "<F12>", "<cmd>ZoomWinTabToggle<cr>", def_opt)
map("t", "<F12>", "<cmd>ZoomWinTabToggle<cr>", def_opt)
map("", "<F12>", "<cmd>ZoomWinTabToggle<cr>", def_opt)
map("i", "<F12>", "<cmd>ZoomWinTabToggle<cr>", def_opt)
map("t", "<F12>", "<cmd>ZoomWinTabToggle<cr>", def_opt)
