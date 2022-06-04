local fn = vim.fn
local cmd = vim.cmd
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
  cmd("packadd packer.nvim")
end

local get_cmds = require("myconfig.mappings").get_cmds

require("packer").startup(function(use)
  -- packer
  use({
    "wbthomason/packer.nvim",
    config = function()
      require("myconfig.plugins.packer")
    end,
  })

  use("mizlan/iswap.nvim")

  -- stdlib
  use("nvim-lua/plenary.nvim")

  -- color
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
      "onsails/lspkind.nvim",
      "williamboman/nvim-lsp-installer",
      -- "ray-x/lsp_signature.nvim",
      "kosayoda/nvim-lightbulb",
      {
        "j-hui/fidget.nvim",
        config = function()
          require("fidget").setup({})
        end,
      },
      "b0o/schemastore.nvim",
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
  })

  -- treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    requires = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      "nvim-treesitter/playground",
      "p00f/nvim-ts-rainbow",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "mfussenegger/nvim-ts-hint-textobject",
      "nvim-treesitter/nvim-treesitter-context",
      "windwp/nvim-ts-autotag",
      "David-Kunz/treesitter-unit",
    },
    run = ":TSUpdate",
    config = function()
      require("myconfig.plugins.treesitter")
    end,
  })
  use({
    "m-demare/hlargs.nvim",
    config = function()
      require("myconfig.plugins.hlargs")
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

  -- statusline
  use({
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", { "SmiteshP/nvim-gps" } },
    config = function()
      require("myconfig.plugins.lualine")
    end,
  })

  -- copilot
  use({
    "zbirenbaum/copilot.lua",
    event = { "VimEnter" },
    config = function()
      vim.defer_fn(function()
        require("copilot").setup()
      end, 100)
    end,
  })
  use({
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua", "nvim-cmp" },
  })

  -- repl
  use({
    "hkupty/iron.nvim",
    config = function()
      require("myconfig.plugins.iron")
    end,
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
    "numToStr/Comment.nvim",
    config = function()
      require("myconfig.plugins.comment-nvim")
    end,
  })

  -- quickfix
  use({
    "kevinhwang91/nvim-bqf",
    config = function()
      require("myconfig.plugins.bqf")
    end,
  })

  -- trouble
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

  -- find highlight
  use({
    "kevinhwang91/nvim-fFHighlight",
    config = function()
      require("fFHighlight").setup()
    end,
  })

  -- hop
  use({
    "phaazon/hop.nvim",
    cmd = get_cmds("hop"),
    config = function()
      require("myconfig.plugins.hop")
    end,
  })

  -- rooter
  use({
    "jedi2610/nvim-rooter.lua",
    config = function()
      require("myconfig.plugins.nvim-rooter")
    end,
  })

  -- todo
  use({
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("myconfig.plugins.todo-comments")
    end,
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
  use("tpope/vim-repeat")
  use("tpope/vim-surround")
  use("tpope/vim-sleuth")
  use({ "foosoft/vim-argwrap", cmd = get_cmds("argwrap") })
  use({ "AndrewRadev/sideways.vim", cmd = get_cmds("sideways") })
end)
