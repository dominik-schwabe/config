local map = vim.api.nvim_set_keymap

local def_opt = {noremap = true, silent = true}

require("todo-comments").setup({})

map("n", "<space>-", "<CMD>:TodoQuickFix<CR>", def_opt)
