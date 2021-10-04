local map = vim.api.nvim_set_keymap

local def_opt = {noremap = true, silent = true}

map('n', 'm', "<CMD>lua require'hop'.hint_char1()<CR>", def_opt)
map('n', 'M', "<CMD>lua require'hop'.hint_words()<CR>", def_opt)
