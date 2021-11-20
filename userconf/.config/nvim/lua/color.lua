local opt = vim.opt
local g = vim.g
local cmd = vim.cmd

opt.termguicolors = true

g.NVIM_TUI_ENABLE_TRUE_COLOR = 1

g.tokyonight_transparent = true
g.tokyonight_terminal_colors = false

cmd("syntax on")

cmd("colorscheme " .. require("config").colorscheme)

local monokai = require("monokai")
local colors = monokai.classic
monokai.setup({
	custom_hlgroups = {
		LineNr = {},
		Normal = {},
		SignColumn = {},
		Visual = { bg = "#555555" },
		TSConstructor = { fg = colors.aqua, style = "bold" },
		TSTextReference = { fg = colors.yellow },
		TSText = { fg = colors.yellow },
		TSTag = { fg = colors.aqua },
		TSNone = { fg = colors.yellow },
		TSKeywordReturn = { fg = colors.purple, style = "bold" },
		TSTagAttribute = { fg = colors.base7 },
		TSProperty = { fg = colors.base7 },
		TSComment = { fg = colors.base6 },
		-- TSParameterReference  = { fg = colors.green },
		-- TSPunctDelimiter = { fg = colors.green },
		-- TSPunctBracket = { fg = colors.green },
		-- TSTagDelimiter = { fg = colors.green },
		-- TSField = { fg = colors.green },
		-- TSAttribute  = { fg = colors.green },
		-- TSBoolean  = { fg = colors.green },
		-- TSCharacter  = { fg = colors.green },
		-- TSDanger = { fg = colors.green },
		-- TSStrong = { fg = colors.green },
		-- TSStrike = { fg = colors.green },
		-- TSNote = { fg = colors.green },
		-- TSMath = { fg = colors.green },
		-- TSLiteral = { fg = colors.green },
		-- TSError = { fg = colors.green },
		-- TSEnviromentName = { fg = colors.green },
		-- TSEnviroment = { fg = colors.green },
		-- TSEmphasis = { fg = colors.green },
		-- TSSymbol = { fg = colors.green },
		-- TSWarning = { fg = colors.green },
		-- TSUnderline = { fg = colors.green },
		-- TSURI = { fg = colors.green },
		-- TSTypeBuiltin = { fg = colors.green },
		-- TSTitle = { fg = colors.green },
	},
})

cmd([[ hi LineNr guibg=none ]])
cmd([[ hi Normal guibg=none ]])
cmd([[ hi SignColumn guibg=none ]])

cmd([[ hi def link LspReferenceText CursorLine ]])
cmd([[ hi def link LspReferenceWrite CursorLine ]])
cmd([[ hi def link LspReferenceRead CursorLine ]])
cmd([[ hi TrailingWhitespace guibg=#880000 ]])
cmd([[ hi clear Conceal ]])

require("colorizer").setup()
