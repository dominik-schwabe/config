local fn = vim.fn
local cmd = vim.cmd
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
	fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
	cmd("packadd packer.nvim")
end

local get_cmds = require("mappings").get_cmds

require("packer").startup(function(use)
	-- packer
	use({
		"wbthomason/packer.nvim",
		config = function()
			require("./plugins.packer")
		end,
	})

	-- color
	use("tanvirtin/monokai.nvim")
	use("norcalli/nvim-colorizer.lua")

	-- complete
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "andersevenrud/compe-tmux", branch = "cmp" },
		},
		config = function()
			require("plugins.cmp")
		end,
	})

	-- lsp
	use({
		"neovim/nvim-lspconfig",
		requires = {
			{ "jose-elias-alvarez/null-ls.nvim", requires = { "nvim-lua/plenary.nvim" } },
			"RRethy/vim-illuminate",
			"onsails/lspkind-nvim",
			{ "RishabhRD/nvim-lsputils", requires = { "RishabhRD/popfix" } },
			"williamboman/nvim-lsp-installer",
			"ray-x/lsp_signature.nvim",
			"kosayoda/nvim-lightbulb",
			"b0o/schemastore.nvim",
		},
		config = function()
			require("plugins.lsp")
		end,
	})

	-- lint
	use({
		"mfussenegger/nvim-lint",
		config = function()
			require("plugins.nvim-lint")
		end,
		cmd = get_cmds("nvim_lint"),
	})

	-- coc
	-- use {"neoclide/coc.nvim", branch = "release", config = function() require("plugins.coc") end}

	-- treesitter
	use({
		"nvim-treesitter/nvim-treesitter",
		requires = {
			"nvim-treesitter/playground",
			"p00f/nvim-ts-rainbow",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"mfussenegger/nvim-ts-hint-textobject",
			"romgrk/nvim-treesitter-context",
			"windwp/nvim-ts-autotag",
			"David-Kunz/treesitter-unit",
		},
		run = ":TSUpdate",
		config = function()
			require("plugins.treesitter")
		end,
	})

	-- telescope
	use({
		"nvim-telescope/telescope.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		config = function()
			require("plugins.telescope")
		end,
		cmd = get_cmds("telescope"),
	})

	-- tree
	use({
		"kyazdani42/nvim-tree.lua",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("plugins.nvim-tree")
		end,
	})

	-- snippets
	use({
		"L3MON4D3/LuaSnip",
		requires = { "rafamadriz/friendly-snippets" },
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	})

	-- dap
	use({
		"mfussenegger/nvim-dap",
		requires = { "Pocco81/DAPInstall.nvim", "rcarriga/nvim-dap-ui" },
		config = function()
			require("plugins.dap")
		end,
		cmd = get_cmds("dap"),
	})

	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", { "SmiteshP/nvim-gps" } },
		config = function()
			require("plugins.lualine")
		end,
	})

	-- repl
	use({
		"hkupty/iron.nvim",
		config = function()
			require("plugins.iron")
		end,
		cmd = get_cmds("iron"),
	})

	-- git
	use({
		"tpope/vim-fugitive",
		config = function()
			require("plugins.fugitive")
		end,
	})

	-- symbols
	use({ "simrat39/symbols-outline.nvim" })

	-- tmux
	use({
		"aserowy/tmux.nvim",
		config = function()
			require("plugins.tmux")
		end,
		cond = function()
			return os.getenv("TMUX") ~= nil
		end,
	})

	-- tex
	use({
		"lervag/vimtex",
		config = function()
			require("plugins.vimtex")
		end,
	})

	-- comment
	use({
		"b3nj5m1n/kommentary",
		config = function()
			require("plugins.kommentary")
		end,
		cmd = get_cmds("kommentary"),
	})

	-- quickfix
	use({
		"kevinhwang91/nvim-bqf",
		config = function()
			require("plugins.bqf")
		end,
	})
	use({
		"folke/trouble.nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("plugins.trouble")
		end,
		cmd = get_cmds("trouble"),
	})

	-- runner
	use({
		"CRAG666/code_runner.nvim",
		config = function()
			require("plugins.code_runner")
		end,
		cmd = get_cmds("code_runner"),
	})

	-- markdown
	use({
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		config = function()
			require("plugins.markdown-preview")
		end,
	})

	-- nvim
	use({
		"phaazon/hop.nvim",
		cmd = get_cmds("hop"),
		config = function()
			require("plugins.hop")
		end,
	})
	use({
		"ahmedkhalf/project.nvim",
		config = function()
			require("plugins.project")
		end,
	})
	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("plugins.todo-comments")
		end,
		cmd = get_cmds("todo_comments"),
	})
	-- use("pwntester/octo.nvim") -- github issues and pull request
	-- use("matbme/JABS.nvim")

	-- legacy
	use({
		"mhinz/vim-grepper",
		config = function()
			require("plugins.grepper")
		end,
		cmd = get_cmds("grepper"),
	})
	use({
		"jlanzarotta/bufexplorer",
		config = function()
			require("plugins.bufexplorer")
		end,
	})
	use({
		"troydm/zoomwintab.vim",
		config = function()
			require("plugins.zoomwintab")
		end,
		cmd = get_cmds("zoomwintabtoggle"),
	})
	use("haya14busa/vim-asterisk")
	use("wellle/targets.vim")
	use("michaeljsmith/vim-indent-object")
	use("tpope/vim-surround")
	use("mg979/vim-visual-multi")
	use("tpope/vim-repeat")
	use({ "foosoft/vim-argwrap", cmd = get_cmds("argwrap") })
	use({ "AndrewRadev/sideways.vim", cmd = get_cmds("sideways") })
	use("sheerun/vim-polyglot")
end)
