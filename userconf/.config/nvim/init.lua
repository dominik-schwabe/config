require("plugins")
require("options")
require("mappings")
require("custom")
require("color")

local g = vim.g
local api = vim.api
local map = api.nvim_set_keymap

local def_opt = {noremap = true, silent = true}

-- argwrap
map('', 'Y', ':ArgWrap<cr>', def_opt)

-- sideways TODO: find treesitter alternative
map("n", "R", ":SidewaysLeft<cr>", def_opt)
map("n", "U", ":SidewaysRight<CR>", def_opt)

-- eregex.vim
g.eregex_default_enable = 0
