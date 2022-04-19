local def_opt = { noremap = true }

vim.keymap.set("", "<space>p", "<NOP>", def_opt)
vim.keymap.set("", "<space>pi", ":PackerInstall<CR>", def_opt)
vim.keymap.set("", "<space>pr", ":PackerClean<CR>", def_opt)
vim.keymap.set("", "<space>pu", ":PackerUpdate<CR>", def_opt)
vim.keymap.set("", "<space>pc", ":PackerCompile<CR>", def_opt)
vim.keymap.set("", "<space>ps", ":PackerSync<CR>", def_opt)
vim.keymap.set("", "<space>pp", ":PackerStatus<CR>", def_opt)
vim.keymap.set("", "<space>pb", ":PackerCompile profile=true<CR>", def_opt)
vim.keymap.set("", "<space>pv", ":PackerProfile<CR>", def_opt)
