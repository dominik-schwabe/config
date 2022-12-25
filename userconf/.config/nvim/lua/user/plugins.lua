local fn = vim.fn
local cmd = vim.cmd

local config = require("user.config")

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

local packer_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap =
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
  cmd("packadd packer.nvim")
end

local function loader(plugin_name)
  plugin_name = plugin_name:gsub("^n?vim%-", "")
  plugin_name = plugin_name:gsub("%.lua$", "")
  plugin_name = plugin_name:gsub("%.n?vim$", "")
  plugin_name = plugin_name:lower()
  local src = "user.plugins." .. plugin_name
  local success, message = pcall(require, src)
  if not success then
    vim.notify(
      "loader for '" .. plugin_name .. "' failed (used name: '" .. plugin_name .. "')" .. "\n" .. message,
      vim.log.levels.INFO
    )
  end
end

local function setup_loader(plugin_name)
  plugin_name = plugin_name:gsub("^n?vim%-", "")
  plugin_name = plugin_name:gsub("%.lua$", "")
  plugin_name = plugin_name:gsub("%.n?vim$", "")
  plugin_name = plugin_name:lower()
  local src = plugin_name
  local success, pkg = pcall(require, src)
  if success then
    pkg.setup()
  else
    vim.notify(
      "setup_loader for '" .. plugin_name .. "' failed (used name: '" .. plugin_name .. "')" .. "\n" .. pkg,
      vim.log.levels.INFO
    )
  end
end

local function setup_loader_raw(plugin_name)
  local src = plugin_name
  local success, pkg = pcall(require, src)
  if success then
    pkg.setup()
  else
    vim.notify(
      "setup_loader_raw for '" .. plugin_name .. "' failed (used name: '" .. plugin_name .. "'" .. "\n" .. pkg,
      vim.log.levels.ERROR
    )
  end
end

require("packer").startup(function(use)
  use({ "ibhagwan/fzf-lua", requires = { "nvim-tree/nvim-web-devicons" } })
  use({ "wbthomason/packer.nvim", config = loader })
  use({ "kylechui/nvim-surround", config = setup_loader_raw })
  use({ "nvim-lua/plenary.nvim" })
  use({ "neovim/nvim-lspconfig", config = loader })
  use({ "williamboman/mason.nvim", config = setup_loader })
  use({ "williamboman/mason-lspconfig.nvim" })
  use({ "jose-elias-alvarez/null-ls.nvim", config = loader })
  use({ "nvim-telescope/telescope.nvim", config = loader })
  use({ "hrsh7th/nvim-cmp", config = loader })
  use({ "hrsh7th/cmp-nvim-lsp" })
  use({ "hrsh7th/cmp-buffer" })
  use({ "saadparwaiz1/cmp_luasnip" })
  use({ "L3MON4D3/LuaSnip", config = loader })
  use({ "rafamadriz/friendly-snippets" })
  use({ "kyazdani42/nvim-tree.lua", config = loader })
  use({ "kevinhwang91/nvim-bqf", config = loader })
  use({ "numToStr/Comment.nvim", config = loader })
  use({ "matbme/JABS.nvim", config = loader })
  use({ "wellle/targets.vim" })
  use({ "mg979/vim-visual-multi", config = loader })
  use({ "mbbill/undotree" })
  use({ "MunifTanjim/nui.nvim" })

  if not config.minimal then
    use({ "kyazdani42/nvim-web-devicons" })
    use({ "johmsalas/text-case.nvim", config = loader })
    use({ "stevearc/dressing.nvim", config = loader })
    use({ "nvim-lualine/lualine.nvim", config = loader })
    use({ "monaqa/dial.nvim", config = loader })
    use({ "rhysd/clever-f.vim" })
    use({ "windwp/nvim-autopairs", config = loader })
    use({ "tpope/vim-sleuth" })
    use({ "lewis6991/impatient.nvim" })
    use({ "NvChad/nvim-colorizer.lua" })
    use({ "hrsh7th/cmp-path" })
    use({ "hrsh7th/cmp-nvim-lua" })
    use({ "andersevenrud/cmp-tmux" })
    use({ "RRethy/vim-illuminate", config = loader })
    use({ "onsails/lspkind.nvim" })
    use({ "WhoIsSethDaniel/mason-tool-installer.nvim" })
    use({ "b0o/schemastore.nvim" })
    use({ "simrat39/rust-tools.nvim" })
    use({ "saecki/crates.nvim", event = { "BufRead Cargo.toml" }, config = setup_loader })
    use({ "nvim-treesitter/nvim-treesitter", config = loader })
    use({ "p00f/nvim-ts-rainbow" })
    use({ "m-demare/hlargs.nvim", config = loader })
    use({ "Wansmer/treesj", config = loader })
    use({ "JoosepAlviste/nvim-ts-context-commentstring" })
    use({ "nvim-treesitter/playground" })
    use({ "nvim-treesitter/nvim-treesitter-textobjects" })
    use({ "nvim-treesitter/nvim-treesitter-context" })
    use({ "windwp/nvim-ts-autotag" })
    use({ "David-Kunz/treesitter-unit" })
    use({ "SmiteshP/nvim-navic" })
    use({ "mfussenegger/nvim-dap", config = loader })
    use({ "rcarriga/nvim-dap-ui" })
    use({ "mfussenegger/nvim-dap-python" })
    use({ "theHamsta/nvim-dap-virtual-text" })
    use({ "tpope/vim-fugitive", config = loader })
    use({ "simrat39/symbols-outline.nvim", config = loader })
    use({ "lervag/vimtex", config = loader })
    use({ "https://gitlab.com/yorickpeterse/nvim-pqf", config = setup_loader })
    use({ "folke/todo-comments.nvim", config = loader })
    use({ "AndrewRadev/sideways.vim", config = loader })
    use({ "ziontee113/icon-picker.nvim", config = loader })
    use({ "ggandor/leap.nvim", config = loader })
    use({ "lark-parser/vim-lark-syntax" })
    use({ "sheerun/vim-polyglot" })
    use({
      "iamcco/markdown-preview.nvim",
      run = "cd app && npm install",
      config = loader,
    })
  end

  -- use({ "CRAG666/code_runner.nvim" })
  -- use({ "mfussenegger/nvim-lint", config = loader })
  -- use({ "Wansmer/sibling-swap.nvim", config = setup_loader })
  -- use({ "pwntester/octo.nvim" }) -- github issues and pull request
  -- use({ "NTBBloodbath/rest.nvim" })
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
  -- use({ "David-Kunz/markid" })
  -- use({ "tpope/vim-repeat" })
  -- use({ "akinsho/toggleterm.nvim", config = loader })
  -- use({ "kosayoda/nvim-lightbulb" })

  if packer_bootstrap then
    require("packer").sync()
  end
end)
