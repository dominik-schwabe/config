local fn = vim.fn
local cmd = vim.cmd
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
  cmd("packadd packer.nvim")
end

require("packer").startup(function(use)
  -- packer
  use({
    "wbthomason/packer.nvim",
    config = function()
      require("user.plugins.packer")
    end,
  })

  use({
    "windwp/nvim-autopairs",
    config = function()
      require("user.plugins.nvim-autopairs")
    end,
  })

  use({
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  })

  -- use({
  --   "VonHeikemen/fine-cmdline.nvim",
  --   requires = {
  --     { "MunifTanjim/nui.nvim" },
  --   },
  -- })

  -- use({
  --   "VonHeikemen/searchbox.nvim",
  --   requires = {
  --     { "MunifTanjim/nui.nvim" },
  --   },
  -- })

  -- indent
  use("tpope/vim-sleuth")

  -- fast startup
  use("lewis6991/impatient.nvim")

  -- stdlib
  use("nvim-lua/plenary.nvim")

  -- color
  use("NvChad/nvim-colorizer.lua")

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
      require("user.plugins.cmp")
    end,
  })

  -- lsp
  use({
    "neovim/nvim-lspconfig",
    requires = {
      {
        "RRethy/vim-illuminate",
        config = function()
          require("user.plugins.illuminate")
        end,
      },
      "onsails/lspkind.nvim",
      {
        "williamboman/mason.nvim",
        config = function()
          require("mason").setup()
        end,
      },
      "williamboman/mason-lspconfig.nvim",
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
      require("user.plugins.lsp")
    end,
  })

  -- null-ls
  use({
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("user.plugins.null-ls")
    end,
  })

  -- rust
  use("simrat39/rust-tools.nvim")
  use({
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup()
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
      "nvim-treesitter/nvim-treesitter-context",
      "windwp/nvim-ts-autotag",
      "David-Kunz/treesitter-unit",
    },
    run = ":TSUpdate",
    config = function()
      require("user.plugins.treesitter")
    end,
  })
  use({
    "m-demare/hlargs.nvim",
    config = function()
      require("user.plugins.hlargs")
    end,
  })

  -- telescope
  use({
    "nvim-telescope/telescope.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("user.plugins.telescope")
    end,
  })

  -- tree
  use({
    "kyazdani42/nvim-tree.lua",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("user.plugins.nvim-tree")
    end,
  })

  -- snippets
  use({
    "L3MON4D3/LuaSnip",
    requires = { "rafamadriz/friendly-snippets" },
    config = function()
      require("user.plugins.luasnip")
    end,
  })

  -- ui
  use({
    "stevearc/dressing.nvim",
    config = function()
      require("user.plugins.dressing")
    end,
  })

  -- statusline
  use({
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", { "SmiteshP/nvim-navic" } },
    config = function()
      require("user.plugins.lualine")
    end,
  })
  -- TODO: setup
  -- use({
  --   "AckslD/nvim-trevJ.lua",
  --   config = function()
  --     require("trevj").setup()
  --   end,
  -- })

  -- dap
  use({
    "mfussenegger/nvim-dap",
    requires = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      require("user.plugins.dap")
    end,
  })

  -- toggle term
  use({
    "akinsho/toggleterm.nvim",
    config = function()
      require("user.plugins.toggleterm")
    end,
  })

  -- git
  use({
    "tpope/vim-fugitive",
    config = function()
      require("user.plugins.fugitive")
    end,
  })

  -- symbols
  use({
    "simrat39/symbols-outline.nvim",
    config = function()
      require("user.plugins.symbols_outline")
    end,
  })

  -- tmux
  use({
    "aserowy/tmux.nvim",
    config = function()
      require("user.plugins.tmux")
    end,
    cond = function()
      return os.getenv("TMUX") ~= nil
    end,
  })

  -- tex
  use({
    "lervag/vimtex",
    config = function()
      require("user.plugins.vimtex")
    end,
  })

  -- comment
  use({
    "numToStr/Comment.nvim",
    config = function()
      require("user.plugins.comment-nvim")
    end,
  })

  -- quickfix
  use({
    "kevinhwang91/nvim-bqf",
    config = function()
      require("user.plugins.bqf")
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
      require("user.plugins.trouble")
    end,
  })

  -- markdown
  use({
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    config = function()
      require("user.plugins.markdown-preview")
    end,
  })

  -- icon picker
  use({
    "ziontee113/icon-picker.nvim",
    config = function()
      require("user.plugins.icon-picker")
    end,
  })

  -- enhanced increment decrement
  use({
    "monaqa/dial.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("user.plugins.dial")
    end,
  })

  -- jump
  use("rhysd/clever-f.vim")
  use({
    "ggandor/leap.nvim",
    config = function()
      require("leap").set_default_keymaps()
    end,
  })

  -- rooter
  use({
    "dominik-schwabe/project.nvim",
    -- "ahmedkhalf/project.nvim",
    config = function()
      require("user.plugins.project-nvim")
    end,
  })

  -- todo
  use({
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("user.plugins.todo-comments")
    end,
  })

  -- zoom
  use({
    "nyngwang/NeoZoom.lua",
    config = function()
      require("user.plugins.neo-zoom")
    end,
  })

  -- repeat motion commands
  -- use({
  --   "jonatan-branting/nvim-better-n",
  --   config = function()
  --     require("user.plugins.better-n")
  --   end,
  -- })

  -- use("pwntester/octo.nvim") -- github issues and pull request
  -- use("NTBBloodbath/rest.nvim")
  -- use({"matbme/JABS.nvim", config=function ()
  -- require("user.plugins.jabs")
  -- end})

  -- legacy
  use("lark-parser/vim-lark-syntax")
  use({
    "jlanzarotta/bufexplorer",
    config = function()
      require("user.plugins.bufexplorer")
    end,
  })
  use({
    "haya14busa/vim-asterisk",
    config = function()
      require("user.plugins.asterisk")
    end,
  })
  use("wellle/targets.vim")
  use("michaeljsmith/vim-indent-object")
  use({
    "mg979/vim-visual-multi",
    config = function()
      require("user.plugins.visual-multi")
    end,
  })
  use("tpope/vim-repeat")
  -- use("tpope/vim-surround")
  use({
    "foosoft/vim-argwrap",
    config = function()
      require("user.plugins.argwrap")
    end,
  })
  use({
    "AndrewRadev/sideways.vim",
    config = function()
      require("user.plugins.sideways")
    end,
  })

  use({
    "hkupty/iron.nvim",
    config = function()
      require("user.plugins.iron")
    end,
  })

  use("mbbill/undotree")

  -- runner
  -- use({
  --   "CRAG666/code_runner.nvim",
  --   config = function()
  --     require("user.plugins.code_runner")
  --   end,
  -- })

  -- lint
  -- use({
  --   "mfussenegger/nvim-lint",
  --   config = function()
  --     require("user.plugins.nvim-lint")
  --   end,
  -- })
end)
