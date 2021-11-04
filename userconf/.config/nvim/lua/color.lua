local opt = vim.opt
local g = vim.g
local cmd = vim.cmd

opt.termguicolors = true

g.NVIM_TUI_ENABLE_TRUE_COLOR = 1

g.tokyonight_transparent = true
g.tokyonight_terminal_colors = false
-- g.tokyonight_style = 'storm'
g.tokyonight_style = 'night'

cmd('syntax on')

cmd('colorscheme ' .. require("config").colorscheme)

-- cmd([[ hi LineNr guibg=none ]])
-- cmd([[ hi Normal guibg=none ]])
-- cmd([[ hi SignColumn guibg=none ]])
-- cmd([[ hi LineNr guibg=#141b24 ]])
-- cmd([[ hi Normal guibg=#141b24 ]])
-- cmd([[ hi EndOfBuffer guibg=#141b24 ]])
-- cmd([[ hi SignColumn guibg=#141b24 ]])
cmd([[ hi clear Conceal ]])
cmd [[ hi def link LspReferenceText CursorLine ]]
cmd [[ hi def link LspReferenceWrite CursorLine ]]
cmd [[ hi def link LspReferenceRead CursorLine ]]
-- cmd [[ hi Visual guibg=#555555 ]]

require("colorizer").setup()
