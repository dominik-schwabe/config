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

-- sideways TODO: fix iswap
map("n", "R", ":SidewaysLeft<cr>", def_opt)
map("n", "U", ":SidewaysRight<CR>", def_opt)

-- eregex.vim
g.eregex_default_enable = 0

local ui = api.nvim_list_uis()[1]
require 'jabs'.setup {
    position = 'corner', -- center, corner
   	width = 50,
   	height = 10,
   	border = 'shadow', -- none, single, double, rounded, solid, shadow, (or an array or chars)

    -- Options for preview window
    preview_position = 'left', -- top, bottom, left, right
    preview = {
        width = 40,
        height = 30,
        border = 'double', -- none, single, double, rounded, solid, shadow, (or an array or chars)
    },

   	-- the options below are ignored when position = 'center'
    col = ui.width,  -- Window appears on the right
    row = ui.height/2, -- Window appears in the vertical middle
}
