local fn = vim.fn
local cmd = vim.cmd

local config = require("user.config")
local F = require("user.functional")

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

local packer_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap =
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
  cmd("packadd packer.nvim")
end

require("packer").startup(function(use)
  use({ "wbthomason/packer.nvim", config = F.loader("user.plugins.packer") })

  use({
    "kylechui/nvim-surround",
    config = F.loader("nvim-surround", function(surround)
      surround.setup({})
    end),
  })

  use({ "nvim-lua/plenary.nvim" })
  use({ "hrsh7th/nvim-cmp", config = F.loader("user.plugins.cmp") })
  use({ "hrsh7th/cmp-nvim-lsp" })
  use({ "hrsh7th/cmp-buffer" })
  use({ "saadparwaiz1/cmp_luasnip" })
  use({ "hrsh7th/cmp-path" })
  use({ "neovim/nvim-lspconfig", config = F.loader("user.plugins.lsp") })
  use({ "williamboman/mason.nvim", config = F.loader("mason") })
  use({ "williamboman/mason-lspconfig.nvim" })
  use({ "jose-elias-alvarez/null-ls.nvim", config = F.loader("user.plugins.null-ls") })
  use({ "nvim-telescope/telescope.nvim", config = F.loader("user.plugins.telescope") })
  use({ "L3MON4D3/LuaSnip", config = F.loader("user.plugins.luasnip") })
  use({ "rafamadriz/friendly-snippets" })
  use({ "numToStr/Comment.nvim", config = F.loader("user.plugins.comment-nvim") })
  use({ "matbme/JABS.nvim", config = F.loader("user.plugins.jabs") })
  use({ "wellle/targets.vim" })
  use({ "mg979/vim-visual-multi", config = F.loader("user.plugins.visual-multi") })
  use({ "mbbill/undotree" })
  use({ "kevinhwang91/nvim-bqf", config = F.loader("user.plugins.bqf") })

  use({ "kyazdani42/nvim-tree.lua", config = F.loader("user.plugins.nvim-tree") })
  use({ "kyazdani42/nvim-web-devicons" })

  if not config.minimal then
    use({ "stevearc/dressing.nvim", config = F.loader("user.plugins.dressing") })
    use({ "nvim-lualine/lualine.nvim", config = F.loader("user.plugins.lualine") })
    use({ "monaqa/dial.nvim", config = F.loader("user.plugins.dial") })
    use({ "rhysd/clever-f.vim" })
    use({ "windwp/nvim-autopairs", config = F.loader("user.plugins.nvim-autopairs") })

    use({ "tpope/vim-sleuth" })

    use({ "lewis6991/impatient.nvim" })

    use({ "NvChad/nvim-colorizer.lua" })

    use({ "hrsh7th/cmp-nvim-lua" })
    use({ "andersevenrud/cmp-tmux" })

    use({
      "RRethy/vim-illuminate",
      config = function()
        require("user.plugins.illuminate")
      end,
    })
    use("onsails/lspkind.nvim")
    use("WhoIsSethDaniel/mason-tool-installer.nvim")
    use("b0o/schemastore.nvim")
    use("simrat39/rust-tools.nvim")
    use({
      "saecki/crates.nvim",
      event = { "BufRead Cargo.toml" },
      config = function()
        require("crates").setup()
      end,
    })

    use({
      "nvim-treesitter/nvim-treesitter",
      config = function()
        require("user.plugins.treesitter")
      end,
    })
    use("p00f/nvim-ts-rainbow")
    use({
      "m-demare/hlargs.nvim",
      config = function()
        require("user.plugins.hlargs")
      end,
    })
    use({
      "Wansmer/treesj",
      config = function()
        require("user.plugins.treesj")
      end,
    })
    use("JoosepAlviste/nvim-ts-context-commentstring")
    use("nvim-treesitter/playground")
    use("nvim-treesitter/nvim-treesitter-textobjects")
    use("nvim-treesitter/nvim-treesitter-context")
    use("windwp/nvim-ts-autotag")
    use("David-Kunz/treesitter-unit")

    use("SmiteshP/nvim-navic")

    use({
      "mfussenegger/nvim-dap",
      config = function()
        require("user.plugins.dap")
      end,
    })
    use("rcarriga/nvim-dap-ui")
    use("mfussenegger/nvim-dap-python")
    use("theHamsta/nvim-dap-virtual-text")

    use({
      "tpope/vim-fugitive",
      config = function()
        require("user.plugins.fugitive")
      end,
    })

    use({
      "simrat39/symbols-outline.nvim",
      config = function()
        require("user.plugins.symbols_outline")
      end,
    })

    use({
      "aserowy/tmux.nvim",
      config = function()
        require("user.plugins.tmux")
      end,
      cond = function()
        return os.getenv("TMUX") ~= nil
      end,
    })

    use({
      "lervag/vimtex",
      config = function()
        require("user.plugins.vimtex")
      end,
    })

    use({
      "https://gitlab.com/yorickpeterse/nvim-pqf",
      config = function()
        require("pqf").setup()
      end,
    })

    use({
      "folke/todo-comments.nvim",
      config = function()
        require("user.plugins.todo-comments")
      end,
    })

    use({
      "AndrewRadev/sideways.vim",
      config = function()
        require("user.plugins.sideways")
      end,
    })

    use({
      "iamcco/markdown-preview.nvim",
      run = "cd app && npm install",
      config = function()
        require("user.plugins.markdown-preview")
      end,
    })

    use({
      "ziontee113/icon-picker.nvim",
      config = function()
        require("user.plugins.icon-picker")
      end,
    })

    use({
      "ggandor/leap.nvim",
      config = function()
        require("leap").set_default_keymaps()
      end,
    })

    use("lark-parser/vim-lark-syntax")
    use("sheerun/vim-polyglot")
  end

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

  -- use({
  --   "Wansmer/sibling-swap.nvim",
  --   config = function()
  --     require("sibling-swap").setup({})
  --   end,
  -- })

  -- use("pwntester/octo.nvim") -- github issues and pull request
  -- use("NTBBloodbath/rest.nvim")

  -- use({
  --   "AckslD/swenv.nvim",
  --   config = function()
  --     require("swenv").setup({
  --       get_venvs = function(venvs_path)
  --         return require("swenv.api").get_venvs(venvs_path)
  --       end,
  --       venvs_path = vim.fn.expand("~/.local/share/virtualenvs"),
  --       post_set_venv = nil,
  --     })
  --   end,
  -- })

  -- use("David-Kunz/markid")

  -- use("tpope/vim-repeat")

  -- use({
  --   "akinsho/toggleterm.nvim",
  --   config = function()
  --     require("user.plugins.toggleterm")
  --   end,
  -- })

  -- use("kosayoda/nvim-lightbulb")

  if packer_bootstrap then
    require("packer").sync()
  end
end)
