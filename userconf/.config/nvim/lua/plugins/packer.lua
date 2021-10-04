local map = vim.api.nvim_set_keymap
local def_opt = {noremap = true}

map("", "<space>p", "<NOP>", def_opt)
map("", "<space>pi", ":PackerInstall<CR>", def_opt)
map("", "<space>pr", ":PackerClean<CR>", def_opt)
map("", "<space>pu", ":PackerUpdate<CR>", def_opt)
map("", "<space>pc", ":PackerCompile<CR>", def_opt)
map("", "<space>ps", ":PackerSync<CR>", def_opt)
map("", "<space>pp", ":PackerStatus<CR>", def_opt)
map("", "<space>pb", ":PackerCompile profile=true<CR>", def_opt)
map("", "<space>pv", ":PackerProfile<CR>", def_opt)
