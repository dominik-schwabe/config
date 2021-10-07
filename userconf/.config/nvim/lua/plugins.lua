local fn = vim.fn
local cmd = vim.cmd
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  cmd 'packadd packer.nvim'
end
vim.api.nvim_list_bufs()

require('packer').startup(function(use)
  -- packer
  use {'wbthomason/packer.nvim', config = function() require("plugins.packer") end }

  -- color
  -- use 'folke/tokyonight.nvim'
  -- use 'navarasu/onedark.nvim'
  use 'tanvirtin/monokai.nvim'
  use 'norcalli/nvim-colorizer.lua'

  -- complete
  use { 'hrsh7th/nvim-cmp', requires = { "hrsh7th/cmp-nvim-lua", "kdheepak/cmp-latex-symbols", 'hrsh7th/cmp-path', 'mfussenegger/nvim-ts-hint-textobject', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-vsnip', {'andersevenrud/compe-tmux', branch = 'cmp'}},
    config = function() require'plugins.cmp' end
  }

  -- lsp
  use {'neovim/nvim-lspconfig', after = {'nvim-cmp', 'null-ls.nvim'}, requires = {{'jose-elias-alvarez/null-ls.nvim', requires = {'nvim-lua/plenary.nvim'}}, 'RRethy/vim-illuminate', 'onsails/lspkind-nvim', {'RishabhRD/nvim-lsputils', requires = {'RishabhRD/popfix'}}, 'kabouzeid/nvim-lspinstall', 'alexaandru/nvim-lspupdate', 'ray-x/lsp_signature.nvim', 'kosayoda/nvim-lightbulb'}, config = function () require("plugins.lsp") end}
  -- use {'liuchengxu/vista.vim', config = function() require("plugins.vista") end}

  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    requires = {'p00f/nvim-ts-rainbow', 'nvim-treesitter/nvim-treesitter-textobjects', 'romgrk/nvim-treesitter-context', 'RRethy/nvim-treesitter-textsubjects', 'windwp/nvim-ts-autotag'},
    run = ':TSUpdate',
    config = function() require("plugins.treesitter") end
  }

  -- telescope
  use { 'nvim-telescope/telescope.nvim', requires = {'nvim-lua/plenary.nvim'}, config = function() require("plugins.telescope") end }

  -- tree
  use { 'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons', config = function() require("plugins.nvim-tree") end }

  -- snippets
  use 'hrsh7th/vim-vsnip'
  use 'rafamadriz/friendly-snippets'

  -- dap
  use { 'mfussenegger/nvim-dap', requires = {'Pocco81/DAPInstall.nvim', 'rcarriga/nvim-dap-ui'}, config = function() require("plugins.dap") end }

  -- statusline TODO: use 'hoob3rt/lualine.nvim'
  use { 'shadmansaleh/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons', {'SmiteshP/nvim-gps'}}, config = function() require'plugins.lualine' end }

  -- repl
  use { 'urbainvaes/vim-ripple', config = function() require("plugins.ripple") end }

  --git
  use { 'tpope/vim-fugitive', config = function() require("plugins.fugitive") end }

  -- tmux
  use { 'aserowy/tmux.nvim', config = function() require("plugins.tmux") end }

  -- tex
  use { 'lervag/vimtex', config = function() require("plugins.vimtex") end }
  -- use {'jakewvincent/texmagic.nvim', config = function() require("plugins.texmagic") end  }

  -- comment
  use { 'b3nj5m1n/kommentary', config = function() require("plugins.kommentary") end }

  -- quickfix
  use { 'kevinhwang91/nvim-bqf', config = function() require("plugins.bqf") end }
  use {'folke/trouble.nvim', requires = {'kyazdani42/nvim-web-devicons' }, config = function() require("plugins.trouble") end}

  -- runner
  use { 'CRAG666/code_runner.nvim', config = function() require("plugins.code_runner") end }

  -- markdown
  use {'iamcco/markdown-preview.nvim', run = 'cd app && npm install', config = function() require("plugins.markdown-preview") end }

  -- nvim
  use {'phaazon/hop.nvim', config = function() require("plugins.hop") end}
  use {'ahmedkhalf/project.nvim', before = "treesitter.nvim", config = function() require("plugins.project") end}
  use { "folke/todo-comments.nvim", requires = "nvim-lua/plenary.nvim", config = function() require("plugins.todo-comments") end }
  -- use 'pwntester/octo.nvim' -- github issues and pull request
  -- use 'npxbr/glow.nvim'
  -- use 'matbme/JABS.nvim'

  -- legacy
  use {'mhinz/vim-grepper', config = function() require("plugins.grepper") end}
  use {'haya14busa/vim-asterisk', config = function() require("plugins.asterisk") end}
  use {'jlanzarotta/bufexplorer', config = function() require("plugins.bufexplorer") end}
  use {'troydm/zoomwintab.vim', config = function() require("plugins.zoomwintab") end}
  use 'wellle/targets.vim'
  use 'michaeljsmith/vim-indent-object'
  use 'tpope/vim-surround'
  use 'othree/eregex.vim'
  use 'wincent/ferret'
  use 'mg979/vim-visual-multi'
  use 'tpope/vim-repeat'
  use 'foosoft/vim-argwrap'
  use 'AndrewRadev/sideways.vim'
  -- 'sheerun/vim-polyglot',
end)
