local fn = vim.fn
local cmd = vim.cmd
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
  cmd("packadd packer.nvim")
end

local get_cmds = require("myconfig.mappings").get_cmds

require("packer").startup(function(use)
  -- use({
  --   "PlatyPew/format-installer.nvim",
  --   config = function()
  --     require("format-installer").setup()
  --   end,
  -- })

  -- packer
  use({
    "wbthomason/packer.nvim",
    config = function()
      require("myconfig.plugins.packer")
    end,
  })
  -- stdlib
  use("nvim-lua/plenary.nvim")

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
      { "andersevenrud/cmp-tmux" },
    },
    config = function()
      require("myconfig.plugins.cmp")
    end,
  })

  -- lsp
  use({
    "neovim/nvim-lspconfig",
    requires = {
      "RRethy/vim-illuminate",
      "onsails/lspkind-nvim",
      "williamboman/nvim-lsp-installer",
      -- "ray-x/lsp_signature.nvim",
      "kosayoda/nvim-lightbulb",
      {
        "j-hui/fidget.nvim",
        config = function()
          require("fidget").setup({})
        end,
      },
      -- "b0o/schemastore.nvim",
    },
    config = function()
      require("myconfig.plugins.lsp")
    end,
  })

  -- null-ls
  use({
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("myconfig.plugins.null-ls")
    end,
  })

  -- lint
  use({
    "mfussenegger/nvim-lint",
    config = function()
      require("myconfig.plugins.nvim-lint")
    end,
    cmd = get_cmds("nvim_lint"),
  })

  -- coc
  -- use({
  -- 	"neoclide/coc.nvim",
  -- 	branch = "release",
  -- 	config = function()
  -- 		require("myconfig.plugins.coc")
  -- 	end,
  -- })

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
      require("myconfig.plugins.treesitter")
    end,
  })

  -- telescope
  use({
    "nvim-telescope/telescope.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("myconfig.plugins.telescope")
    end,
    cmd = get_cmds("telescope"),
  })

  -- tree
  use({
    "kyazdani42/nvim-tree.lua",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("myconfig.plugins.nvim-tree")
    end,
  })

  -- snippets
  use({
    "L3MON4D3/LuaSnip",
    requires = { "rafamadriz/friendly-snippets" },
    config = function()
      require("myconfig.plugins.luasnip")
    end,
  })

  -- dap
  use({
    "mfussenegger/nvim-dap",
    requires = { "Pocco81/DAPInstall.nvim", "rcarriga/nvim-dap-ui" },
    config = function()
      require("myconfig.plugins.dap")
    end,
    cmd = get_cmds("dap"),
  })

  use({
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", { "SmiteshP/nvim-gps" } },
    config = function()
      require("myconfig.plugins.lualine")
    end,
  })

  -- repl
  use({
    "hkupty/iron.nvim",
    config = function()
      require("myconfig.plugins.iron")
    end,
    cmd = get_cmds("iron"),
  })

  -- git
  use({
    "tpope/vim-fugitive",
    config = function()
      require("myconfig.plugins.fugitive")
    end,
  })

  -- symbols
  use({ "simrat39/symbols-outline.nvim" })

  -- tmux
  use({
    "aserowy/tmux.nvim",
    config = function()
      require("myconfig.plugins.tmux")
    end,
    cond = function()
      return os.getenv("TMUX") ~= nil
    end,
  })

  -- tex
  use({
    "lervag/vimtex",
    config = function()
      require("myconfig.plugins.vimtex")
    end,
  })

  -- comment
  use({
    "b3nj5m1n/kommentary",
    config = function()
      require("myconfig.plugins.kommentary")
    end,
    cmd = get_cmds("kommentary"),
  })

  -- quickfix
  use({
    "kevinhwang91/nvim-bqf",
    config = function()
      require("myconfig.plugins.bqf")
    end,
  })
  use({
    "folke/trouble.nvim",
    requires = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require("myconfig.plugins.trouble")
    end,
    cmd = get_cmds("trouble"),
  })

  -- runner
  use({
    "CRAG666/code_runner.nvim",
    config = function()
      require("myconfig.plugins.code_runner")
    end,
    cmd = get_cmds("code_runner"),
  })

  -- markdown
  use({
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    config = function()
      require("myconfig.plugins.markdown-preview")
    end,
  })

  -- enhanced increment decrement
  use({
    "monaqa/dial.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("myconfig.plugins.dial")
    end,
  })

  -- yank rotate
  -- use("svermeulen/vim-yoink")

  -- nvim
  use({
    "phaazon/hop.nvim",
    cmd = get_cmds("hop"),
    config = function()
      require("myconfig.plugins.hop")
    end,
  })
  use({
    "jedi2610/nvim-rooter.lua",
    config = function()
      require("myconfig.plugins.nvim-rooter")
    end,
  })
  use({
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("myconfig.plugins.todo-comments")
    end,
    cmd = get_cmds("todo_comments"),
  })

  -- use("pwntester/octo.nvim") -- github issues and pull request
  -- use("matbme/JABS.nvim")

  -- legacy
  use({
    "jlanzarotta/bufexplorer",
    config = function()
      require("myconfig.plugins.bufexplorer")
    end,
  })
  use({
    "troydm/zoomwintab.vim",
    config = function()
      require("myconfig.plugins.zoomwintab")
    end,
    cmd = get_cmds("zoomwintabtoggle"),
  })
  use("haya14busa/vim-asterisk")
  use("wellle/targets.vim")
  use("michaeljsmith/vim-indent-object")
  use("mg979/vim-visual-multi")
  use("tpope/vim-surround")
  use("tpope/vim-repeat")
  use("tpope/vim-sleuth")
  use("AndrewRadev/splitjoin.vim")
  use({ "foosoft/vim-argwrap", cmd = get_cmds("argwrap") })
  use({ "AndrewRadev/sideways.vim", cmd = get_cmds("sideways") })
end)
