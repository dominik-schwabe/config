local fn = vim.fn
local cmd = vim.cmd
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
  cmd("packadd packer.nvim")
end

require("packer").startup(function(use)
  -- packer
  use("lewis6991/impatient.nvim")

  use({
    "wbthomason/packer.nvim",
    config = function()
      require("myconfig.plugins.packer")
    end,
  })

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

  -- ui
  use({
    "stevearc/dressing.nvim",
    config = function()
      require("myconfig.plugins.dressing")
    end,
  })

  -- statusline
  use({
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", { "SmiteshP/nvim-gps" } },
    config = function()
      require("myconfig.plugins.lualine")
    end,
  })
  use({
    "AckslD/nvim-trevJ.lua",
    config = function()
      require("trevj").setup()
    end,
  })

  -- dap
  use({
    "mfussenegger/nvim-dap",
    requires = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      require("myconfig.plugins.dap")
    end,
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
  use("simrat39/symbols-outline.nvim")

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
  use({
    "https://gitlab.com/yorickpeterse/nvim-pqf",
    config = function()
      require("pqf").setup()
    end,
  })

  -- trouble
  use({
    "folke/trouble.nvim",
    requires = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require("myconfig.plugins.trouble")
    end,
  })

  -- markdown
  use({
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    config = function()
      require("myconfig.plugins.markdown-preview")
    end,
  })

  -- icon picker
  use({
    "ziontee113/icon-picker.nvim",
    config = function()
      require("icon-picker")
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

  -- zoom
  use({
    "nyngwang/NeoZoom.lua",
    config = function()
      require("myconfig.plugins.neo-zoom")
    end,
  })

  -- repeat motion commands
  -- use({
  --   "jonatan-branting/nvim-better-n",
  --   config = function()
  --     require("myconfig.plugins.better-n")
  --   end,
  -- })

  -- use("pwntester/octo.nvim") -- github issues and pull request
  -- use("matbme/JABS.nvim")
  -- use("NTBBloodbath/rest.nvim")

  -- legacy
  use({
    "jlanzarotta/bufexplorer",
    config = function()
      require("myconfig.plugins.bufexplorer")
    end,
  })

  use("haya14busa/vim-asterisk")
  use("wellle/targets.vim")
  use("michaeljsmith/vim-indent-object")
  use("mg979/vim-visual-multi")
  use("tpope/vim-repeat")
  use("tpope/vim-surround")
  use("tpope/vim-sleuth")
  use({ "foosoft/vim-argwrap" })
  use({ "AndrewRadev/sideways.vim" })

  -- runner
  -- use({
  --   "CRAG666/code_runner.nvim",
  --   config = function()
  --     require("myconfig.plugins.code_runner")
  --   end,
  -- })

  -- copilot
  -- use({
  --   "zbirenbaum/copilot.lua",
  --   event = { "VimEnter" },
  --   config = function()
  --     vim.defer_fn(function()
  --       require("copilot").setup()
  --     end, 100)
  --   end,
  -- })
  -- use({
  --   "zbirenbaum/copilot-cmp",
  --   after = { "copilot.lua", "nvim-cmp" },
  -- })

  -- lint
  -- use({
  --   "mfussenegger/nvim-lint",
  --   config = function()
  --     require("myconfig.plugins.nvim-lint")
  --   end,
  -- })
end)
