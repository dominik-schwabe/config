local F = require("user.functional")
local U = require("user.utils")

local config = require("user.config")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

local function l(plugin_name)
  return function()
    local src = "user.plugins." .. plugin_name
    local success, message = true, require(src)
    if not success then
      vim.notify(
        "loader for '" .. plugin_name .. "' failed (used name: '" .. plugin_name .. "')" .. "\n" .. message,
        vim.log.levels.INFO
      )
    end
  end
end

local function req(plugin_name)
  return setmetatable({}, {
    __index = function(_, method_name)
      return function(...)
        local args = { ... }
        local method = require(plugin_name)[method_name]
        if args[1] then
          return function()
            method(unpack(args))
          end
        end
        method()
      end
    end,
  })
end

local function with_dependencies(plugin, optional_dependencies)
  if not config.minimal then
    plugin.dependencies = plugin.dependencies or {}
    plugin.dependencies = F.concat(plugin.dependencies, optional_dependencies)
  end
  return plugin
end

local function jabs_toggle()
  if vim.bo.filetype == "JABSwindow" then
    vim.cmd("close")
  else
    vim.cmd("JABSOpen")
  end
end

local lspconfig = with_dependencies({
  "neovim/nvim-lspconfig",
  config = l("lspconfig"),
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    { "williamboman/mason-lspconfig.nvim" },
  },
}, {
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  { "SmiteshP/nvim-navic" },
  { "b0o/schemastore.nvim" },
  {
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate").configure({
        providers = { "lsp" },
        filetypes_denylist = config.illuminate_blacklist,
        modes_allowlist = { "n" },
      })
    end,
  },
  { "simrat39/rust-tools.nvim" },
})

local cmp = with_dependencies({
  "hrsh7th/nvim-cmp",
  config = l("cmp"),
  dependencies = {
    { "saadparwaiz1/cmp_luasnip" },
    { "onsails/lspkind.nvim" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
  },
}, {
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-nvim-lua" },
  { "andersevenrud/cmp-tmux" },
})

local nvim_tree = with_dependencies({
  "kyazdani42/nvim-tree.lua",
  config = l("tree"),
  keys = {
    { "<F1>", U.esc_wrap(req("nvim-tree").toggle), mode = { "n", "x", "i", "t" } },
  },
}, { { "kyazdani42/nvim-web-devicons" } })

local comment = with_dependencies(
  { "numToStr/Comment.nvim", config = l("comment"), keys = { { "gc", mode = { "n", "x" } } } },
  { { "JoosepAlviste/nvim-ts-context-commentstring" } }
)

local plugins = {
  lspconfig,
  nvim_tree,
  cmp,
  comment,
  { "L3MON4D3/LuaSnip", config = l("luasnip"), dependencies = {
    { "rafamadriz/friendly-snippets" },
  } },
  { "kylechui/nvim-surround", config = true, event = "InsertEnter" },
  { "nvim-lua/plenary.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
  { "jose-elias-alvarez/null-ls.nvim", config = l("null-ls"), event = "InsertEnter" },
  {
    "nvim-telescope/telescope.nvim",
    config = l("telescope"),
    cmd = "Telescope",
    keys = {
      { "<C-p>", "<CMD>Telescope find_files<CR>", mode = { "n", "x", "i" }, desc = "find files" },
      { "_", "<CMD>Telescope live_grep<CR>", mode = { "n", "x" }, desc = "live grep" },
      { "z=", "<CMD>Telescope spell_suggest<CR><ESC>", desc = "spell suggest" },
      {
        "<space>/",
        "<CMD>Telescope current_buffer_fuzzy_find<CR>",
        mode = { "n", "x" },
        desc = "fuzzy find in current buffer",
      },
      { "<space>h", "<CMD>Telescope help_tags<CR>", mode = { "n", "x" }, desc = "search help tags" },
      { "<space>,,", "<CMD>Telescope resume<CR>", mode = { "n", "x" }, desc = "resume last search" },
      { "<space>,k", "<CMD>Telescope keymaps<CR>", mode = { "n", "x" }, desc = "search keymaps" },
      { "<space>,j", "<CMD>Telescope jumplist<CR>", mode = { "n", "x" }, desc = "search jumplist" },
      { "<space>,y", "<CMD>Telescope yank_history<CR>", mode = { "n", "x" }, desc = "search yank history" },
      { "<space>,q", "<CMD>Telescope macro_history<CR>", mode = { "n", "x" }, desc = "search macro history" },
      { "<space>,d", "<CMD>Telescope diffsplit<CR>", mode = { "n", "x" }, desc = "search diffsplit commits" },
      { "<space>,s", "<CMD>Telescope git_status<CR>", mode = { "n", "x" }, desc = "search changed files" },
    },
  },
  {
    "kevinhwang91/nvim-bqf",
    config = { auto_resize_height = false, func_map = { open = "o", openc = "<CR>" } },
    ft = "qf",
  },
  {
    "matbme/JABS.nvim",
    config = l("jabs"),
    dependencies = { { "kyazdani42/nvim-web-devicons" } },
    keys = { { "<F2>", jabs_toggle, mode = { "n", "x", "i", "t" }, desc = "toggle buffer explorer" } },
  },
  { "wellle/targets.vim" },
  {
    "mg979/vim-visual-multi",
    config = function()
      vim.g.VM_maps = {
        ["Select Cursor Down"] = "L",
        ["Select Cursor Up"] = "K",
      }
    end,
  }, -- TODO: lazy
  { "mbbill/undotree", keys = {
    { "<F3>", "<CMD>UndotreeToggle<CR>", desc = "toggle undo tree" },
  } },
}

if not config.minimal then
  plugins = F.concat(plugins, {
    {
      "johmsalas/text-case.nvim",
      config = l("text-case"),
      keys = { "<space>u", "<space>U", "<space>K", "<space>k", "<space>cs", "<space>ck", "<space>cm", "<space>cp" },
    },
    {
      "stevearc/dressing.nvim",
      config = {
        input = {
          insert_only = false,
          win_options = {
            winblend = 0,
            winhighlight = "",
          },
          override = function(conf)
            conf.col = -1
            conf.row = 0
            return conf
          end,
        },
      },
    },
    {
      "nvim-lualine/lualine.nvim",
      config = l("lualine"),
      dependencies = {
        { "SmiteshP/nvim-navic" },
        { "kyazdani42/nvim-web-devicons" },
      },
    },
    {
      "monaqa/dial.nvim",
      config = l("dial"),
      keys = {
        { "<C-a>", "<Plug>(dial-increment)", mode = { "n", "x" }, desc = "increment next" },
        { "<C-x>", "<Plug>(dial-decrement)", mode = { "n", "x" }, desc = "decrement next" },
        { "g<C-a>", "<Plug>(dial-increment-additional)", mode = "x", desc = "increment additional" },
        { "g<C-x>", "<Plug>(dial-decrement-additional)", mode = "x", desc = "decrement additional" },
      },
    },
    { "rhysd/clever-f.vim", keys = { "f", "F", "t", "T" } },
    { "windwp/nvim-autopairs", config = true, event = "InsertEnter" },
    { "NvChad/nvim-colorizer.lua", config = l("colorizer"), event = "VimEnter" },
    { "saecki/crates.nvim", config = true, event = "BufRead Cargo.toml" },
    {
      "nvim-treesitter/nvim-treesitter",
      config = l("treesitter"),
      dependencies = {
        { "p00f/nvim-ts-rainbow" },
        {
          "m-demare/hlargs.nvim",
          config = {
            color = "#00ffaf", -- "#5fafff" "#04c99b" "#02b4ef"
            excluded_argnames = {
              declarations = {},
              usages = {
                python = { "self", "cls" },
                lua = { "self" },
              },
            },
          },
        },
        { "nvim-treesitter/nvim-treesitter-textobjects" },
        { "nvim-treesitter/nvim-treesitter-context" },
        { "windwp/nvim-ts-autotag" },
        { "David-Kunz/treesitter-unit" },
      },
    },
    {
      "Wansmer/treesj",
      config = l("treesj"),
      keys = { { "Y", req("treesj").toggle, mode = { "n", "x" }, desc = "toggle split join" } },
    },
    { "nvim-treesitter/playground", cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" } },
    {
      "mfussenegger/nvim-dap",
      config = l("dap"),
      dependencies = {
        { "rcarriga/nvim-dap-ui" },
        { "theHamsta/nvim-dap-virtual-text" },
        { "mfussenegger/nvim-dap-python" },
      },
      keys = {
        { "<space>b", req("dap").toggle_breakpoint, desc = "toggle breakpoint" },
        {
          "<space>B",
          F.f(U.input, "Breakpoint condition: ", req("dap").set_breakpoint),
          desc = "set breakpoint condition",
        },
        { "<F5>", req("dap").step_over, desc = "step over" },
        { "<F6>", req("dap").step_into, desc = "step into" },
        { "<F18>", req("dap").step_out, desc = "step out" },
        { "<F8>", req("dap").continue, desc = "continue debugging" },
        { "<F20>", req("dap").terminate, desc = "terminate debugger" },
      },
    },
    {
      "simrat39/symbols-outline.nvim",
      config = { width = 40 },
      keys = { { "<space>as", "<ESC>:SymbolsOutline<CR>", desc = "toggle symbols outline" } },
    },
    { "lervag/vimtex", config = l("vimtex"), ft = "tex" },
    { url = "https://gitlab.com/yorickpeterse/nvim-pqf", config = true },
    {
      "folke/todo-comments.nvim",
      config = {
        search = {
          command = "rg",
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--max-filesize=1M",
            "--ignore-file",
            ".gitignore",
          },
        },
      },
      lazy = false,
      keys = { { "<space>at", "<CMD>TodoQuickFix<CR>", desc = "show todos in quickfix" } },
    },
    {
      "AndrewRadev/sideways.vim",
      keys = {
        { "R", "<CMD>SidewaysLeft<CR>", desc = "swap argument with left argument" },
        { "U", "<CMD>SidewaysRight<CR>", desc = "swap argument with right argument" },
      },
    },
    {
      "ziontee113/icon-picker.nvim",
      config = true,
      keys = { { "<space>ai", "<CMD>PickIcons<CR>", desc = "open icon picker" } },
    },
    { "ggandor/leap.nvim", config = req("leap").set_default_keymaps, keys = { "s", "S" } },
    { "tpope/vim-sleuth" },
    { "lark-parser/vim-lark-syntax" },
    { "sheerun/vim-polyglot" },
    {
      "iamcco/markdown-preview.nvim",
      build = "cd app && npm install",
      lazy = false,
      config = function()
        vim.g.mkdp_auto_start = 0
        vim.g.mkdp_auto_close = 0
      end,
      keys = { { "<space>am", "<CMD>MarkdownPreviewToggle<CR>", desc = "toggle markdown preview" } },
    },
  })
end

require("lazy").setup(plugins, {
  defaults = {
    lazy = false,
    version = "*",
  },
  checker = {
    enabled = false,
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- local unused = {
--   { "CRAG666/code_runner.nvim" },
--   { "mfussenegger/nvim-lint", config = l("lint") },
--   { "Wansmer/sibling-swap.nvim", config = true },
--   { "pwntester/octo.nvim" },
--   { "NTBBloodbath/rest.nvim" },
--   {
--     "AckslD/swenv.nvim",
--     config = function()
--       require("swenv").setup({
--         get_venvs = function(venvs_path)
--           return require("swenv.api").get_venvs(venvs_path)
--         end,
--         venvs_path = vim.fn.expand("~/.local/share/virtualenvs"),
--         post_set_venv = nil,
--       })
--     end,
--   },
--   { "David-Kunz/markid" },
--   { "tpope/vim-repeat" },
--   { "akinsho/toggleterm.nvim", config = l("toggleterm") },
--   { "kosayoda/nvim-lightbulb" },
-- }

vim.keymap.set("n", "<space>ps", "<ESC>:Lazy sync<CR>", { desc = "install, clean, and update plugins" })
