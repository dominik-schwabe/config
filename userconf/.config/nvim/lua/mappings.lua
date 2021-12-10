local map = vim.api.nvim_set_keymap

local no_opt = {}
local def_opt = { noremap = true, silent = true }
local nore_opt = { noremap = true }
local silent_opt = { silent = true }
local unique_opt = { unique = true, noremap = true, silent = true }

local map_info = {}

map_info.asterisk = {
	mappings = {
		["*"] = { { { "n", "x" }, "<Plug>(asterisk-*)", no_opt } },
		["#"] = { { { "n", "x" }, "<Plug>(asterisk-#)", no_opt } },
		["g*"] = { { { "n", "x" }, "<Plug>(asterisk-g*)", no_opt } },
		["g#"] = { { { "n", "x" }, "<Plug>(asterisk-g#)", no_opt } },
		["z*"] = { { { "n", "x" }, "<Plug>(asterisk-z*)", no_opt } },
		["gz*"] = { { { "n", "x" }, "<Plug>(asterisk-gz*)", no_opt } },
		["z#"] = { { { "n", "x" }, "<Plug>(asterisk-z#)", no_opt } },
		["gz#"] = { { { "n", "x" }, "<Plug>(asterisk-gz#)", no_opt } },
	},
}

map_info.bufexplorer = {
	mappings = {
		["<F2>"] = {
			{ { "n", "x", "i" }, "<ESC>:ToggleBufExplorer<CR>", def_opt },
			{ { "t" }, "<CMD>ToggleBufExplorer<CR>", def_opt },
		},
	},
}

map_info.markdown_preview = {
	mappings = {
		["<space>m"] = { { { "n" }, "<CMD>MarkdownPreviewToggle<CR>", def_opt } },
	},
	commands = { "MarkdownPreviewToggle" },
}

map_info.code_runner = {
	mappings = {
		["<leader>r"] = { { { "n" }, "<CMD>RunCode<CR>", def_opt } },
	},
	commands = { "RunCode" },
}

map_info.symbols_outline = {
	mappings = {
		["<F3>"] = { { { "n", "i" }, "<CMD>SymbolsOutline<CR>", def_opt } },
	},
	commands = { "SymbolsOutline" },
}

map_info.dap = {
	mappings = {
		["<F5>"] = { { { "n", "x", "i" }, "<CMD>DapBreakpoint<CR>", def_opt } },
		["<F7>"] = { { { "n", "x", "i" }, "<CMD>DapStepOver<CR>", def_opt } },
		["<F8>"] = { { { "n", "x", "i" }, "<CMD>DapContinue<CR>", def_opt } },
		["<F19>"] = { { { "n", "x", "i" }, "<CMD>DapStepInto<CR>", def_opt } },
		["<F21>"] = { { { "n", "x", "i" }, "<CMD>DapUiToggle<CR>", nore_opt } },
	},
	commands = { "DapBreakpoint", "DapContinue", "DapStepOver", "DapStepInto", "DapUiToggle" },
}

map_info.grepper = {
	mappings = {
		["<c-_>"] = { { { "n" }, "<CMD>GrepWord<CR>", def_opt } },
		["_"] = { { { "n" }, "<CMD>SearchInFiles<CR>", def_opt } },
	},
	commands = { "GrepWord", "SearchInFiles" },
}

map_info.hop = {
	mappings = {
		["m"] = { { { "n" }, "<CMD>HopChar1<CR>", def_opt } },
		["M"] = { { { "n" }, "<CMD>HopWord<CR>", def_opt } },
	},
	commands = { "HopChar1", "HopWord" },
}

map_info.kommentary = {
	mappings = {
		["gc"] = {
			{ { "n" }, "<CMD>CommentLine<CR>", silent_opt },
			{ { "x" }, "<CMD>CommentVisual<CR>", silent_opt },
		},
	},
	commands = { "CommentLine", "CommentVisual" },
}

map_info.lspinstall = {
	mappings = {
		["<space>li"] = { { { "n" }, ":LspInstall ", nore_opt } },
		["<space>lu"] = { { { "n" }, "<CMD>LspUpdate<CR>", nore_opt } },
	},
}

map_info.nvim_lint = {
	mappings = {
		["<F9>"] = { { { "n", "i" }, "<CMD>Lint<CR>", nore_opt } },
	},
	commands = { "Lint" },
}

map_info.treesitter_unit = {
	mappings = {
		["iu"] = { { { "x", "o" }, "<CMD>lua require'treesitter-unit'.select(true)<CR>", def_opt } },
		["au"] = { { { "x", "o" }, "<CMD>lua require'treesitter-unit'.select()<CR>", def_opt } },
	},
}

map_info.nvimtree = {
	mappings = {
		["<F1>"] = {
			{ { "n", "x", "i" }, "<ESC>:NvimTreeToggle<CR>", def_opt },
			{ { "t" }, "<CMD>NvimTreeToggle<CR>", def_opt },
		},
		["gt"] = { { { "n", "x" }, "<ESC>:NvimTreeFindFile<CR>", def_opt } },
	},
	commands = { "NvimTreeToggle", "NvimTreeFindFile" },
}

map_info.iron = {
	mappings = {
		["<CR>"] = {
			{ { "n" }, ":<c-u>ReplSendLine<CR>", def_opt },
			{ { "x" }, ":<c-u>ReplSendSelection<CR>", def_opt },
		},
		["<C-space>"] = {
			{ { "n" }, ":<c-u>ReplSendParagraph<CR>", def_opt },
			{ { "x" }, ":<c-u>ReplSendSelection<CR>", def_opt },
		},
		["<leader><space>"] = { { { "n" }, ":<c-u>ReplSendBuffer<CR>", def_opt } },
		["<F4>"] = {
			{ { "n" }, ":ReplOpen<CR><ESC>", def_opt },
			{ { "i" }, "<cmd>ReplOpen<CR>", def_opt },
		},
	},
	commands = { "ReplSendLine", "ReplSendParagraph", "ReplSendSelection", "ReplSendBuffer", "ReplOpen" },
}

map_info.telescope = {
	mappings = {
		["<C-p>"] = { { { "n", "x", "i" }, "<CMD>Telescope find_files<CR>", def_opt } },
		["<F11>"] = { { { "n", "x", "i" }, "<CMD>Telescope live_grep<CR>", def_opt } },
		["z="] = { { { "n" }, "<CMD>Telescope spell_suggest<CR><ESC>", def_opt } },
		["<space>jj"] = { { { "n", "x" }, "<CMD>Telescope resume<CR>", def_opt } },
		["<space>jc"] = { { { "n", "x" }, "<CMD>Telescope highlights<CR>", def_opt } },
		["<space>jk"] = { { { "n", "x" }, "<CMD>Telescope keymaps<CR>", def_opt } },
		["<space>jgb"] = { { { "n", "x" }, "<CMD>Telescope git_branches<CR>", def_opt } },
		["<space>jgs"] = { { { "n", "x" }, "<CMD>Telescope git_status<CR>", def_opt } },
		["<space>jh"] = { { { "n", "x" }, "<CMD>Telescope help_tags<CR>", def_opt } },
		["<space>jl"] = { { { "n", "x" }, "<CMD>Telescope jumplist<CR>", def_opt } },
		["<space>js"] = { { { "n", "x" }, "<CMD>Telescope document_symbols<CR>", def_opt } },
		["<space>jb"] = { { { "n", "x" }, "<CMD>Telescope current_buffer_fuzzy_find<CR>", def_opt } },
	},
	commands = { "Telescope" },
}

map_info.todo_comments = {
	mappings = {
		["<space>-"] = { { { "n" }, "<CMD>:TodoQuickFix<CR>", def_opt } },
	},
	commands = { "TodoQuickFix" },
}

map_info.trouble = {
	mappings = {
		["ä"] = { { { "n", "x" }, "<cmd>TroubleToggle document_diagnostics<cr>", def_opt } },
	},
	commands = { "TroubleToggle" },
}

map_info.zoomwintabtoggle = {
	mappings = {
		["<F12>"] = { { { "n", "x", "i", "t" }, "<cmd>ZoomWinTabToggle<cr>", def_opt } },
	},
	commands = { "ZoomWinTabToggle" },
}

map_info.argwrap = {
	mappings = {
		["Y"] = { { { "n", "x" }, ":ArgWrap<cr>", def_opt } },
	},
	commands = { "ArgWrap" },
}

-- sideways TODO: find treesitter alternative
map_info.sideways = {
	mappings = {
		["R"] = { { { "n" }, ":SidewaysLeft<cr>", def_opt } },
		["U"] = { { { "n" }, ":SidewaysRight<CR>", def_opt } },
	},
	commands = { "SidewaysLeft", "SidewaysRight" },
}

map_info.default = {
	mappings = {
		["p"] = { { { "x" }, '"_dP', def_opt } },
		["<space>P"] = { { { "x" }, "p", def_opt } },
		["Q"] = { { { "n", "x" }, ":qa<CR>", def_opt } },
		["<left>"] = { { { "n", "x", "i" }, "<CMD>wincmd H<CR>", def_opt } },
		["<right>"] = { { { "n", "x", "i" }, "<CMD>wincmd L<CR>", def_opt } },
		["<up>"] = { { { "n", "x", "i" }, "<CMD>wincmd K<CR>", def_opt } },
		["<down>"] = { { { "n", "x", "i" }, "<CMD>wincmd J<CR>", def_opt } },
		["ö"] = { { { "n", "x" }, "<CMD>noh<CR>", def_opt } },
		["<space>k"] = { { { "n", "x" }, "lua d(vim.fn.mode())", def_opt } },
		["<"] = { { { "x" }, "<gv", def_opt } },
		[">"] = { { { "x" }, ">gv", def_opt } },
		["<C-h>"] = {
			{ { "n", "x", "i" }, "<CMD>wincmd h<CR>", nore_opt },
			{ { "t" }, "<C-\\><C-n>:TermGoDirection h<CR>", def_opt },
		},
		["<C-j>"] = {
			{ { "n", "x", "i" }, "<CMD>wincmd j<CR>", nore_opt },
			{ { "t" }, "<C-\\><C-n>:TermGoDirection j<CR>", def_opt },
		},
		["<C-k>"] = {
			{ { "n", "x", "i" }, "<CMD>wincmd k<CR>", nore_opt },
			{ { "t" }, "<C-\\><C-n>:TermGoDirection k<CR>", def_opt },
		},
		["<C-l>"] = {
			{ { "n", "x", "i" }, "<CMD>wincmd l<CR>", nore_opt },
			{ { "t" }, "<C-\\><C-n>:TermGoDirection l<CR>", def_opt },
		},
		["db"] = { { { "n" }, "dvb", def_opt } },
		["cb"] = { { { "n" }, "cvb", def_opt } },
		["<C-g>"] = { { { "n" }, "2<C-g>", nore_opt } },
		["<leader>x"] = { { { "n", "x" }, "<CMD>ChmodSet<CR>", def_opt } },
		["<leader>X"] = { { { "n", "x" }, "<CMD>ChmodRemove<CR>", def_opt } },
		["Ä"] = { { { "n", "x" }, "<CMD>LoclistToggle<CR>", def_opt } },
		["Ö"] = { { { "n", "x" }, "<CMD>QuickfixToggle<CR>", def_opt } },
		["<space>lds"] = { { { "n" }, "<CMD>LspSettings<CR>", def_opt } },
		["<space>ldr"] = { { { "n" }, "<CMD>LspRoot<CR>", def_opt } },
		["<space>s"] = { { { "x" }, "<CMD>SubstitudeSelection<CR>", def_opt } },
		["gl"] = { { { "n" }, "<CMD>LatexSubstitude<CR>", def_opt } },
		["+"] = { { { "n", "x" }, "<cmd>SmartResizeExpand<cr>", def_opt } },
		["-"] = { { { "n", "x" }, "<cmd>SmartResizeReduce<cr>", def_opt } },
		["<F10>"] = {
			{ { "n", "x", "t" }, "<CMD>ToggleTermBottom<CR>", def_opt },
			{ { "i" }, "<ESC>:ToggleTermBottom<CR>", def_opt },
		},
		["<F22>"] = {
			{ { "n", "x", "t" }, "<CMD>ToggleTermRight<CR>", def_opt },
			{ { "i" }, "<ESC>:ToggleTermRight<CR>", def_opt },
		},
		["<space>ss"] = { { { "n", "x" }, "<CMD>SetSpell<CR>", def_opt } },
		["<space>sd"] = { { { "n", "x" }, "<CMD>SetSpell de_de<CR>", def_opt } },
		["<space>se"] = { { { "n", "x" }, "<CMD>SetSpell en_us<CR>", def_opt } },
	},
}

M = {}

function M.setup()
	for _, plug_info in pairs(map_info) do
		for key, mappings in pairs(plug_info.mappings) do
			for _, mapping in pairs(mappings) do
				local modes, command, map_opts = unpack(mapping)
				for _, mode in pairs(modes) do
					map(mode, key, command, map_opts)
				end
			end
		end
	end
end

function M.get_keys(plugin)
	local keys = {}
	for key, _ in pairs(map_info[plugin].mappings) do
		keys[#keys + 1] = key
	end
	return keys
end

function M.get_cmds(plugin)
	return map_info[plugin].commands or {}
end

return M
