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

local function creq(plugin_name)
  return setmetatable({}, {
    __index = function(_, method_name)
      return function(...)
        local args = { ... }
        return function()
          local method = require(plugin_name)[method_name]
          method(unpack(args))
        end
      end
    end,
  })
end

local function req(plugin_name)
  return setmetatable({}, {
    __index = function(_, method_name)
      return function(...)
        local args = { ... }
        local method = require(plugin_name)[method_name]
        return method(unpack(args))
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
  -- { "folke/neodev.nvim" },
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
  -- {
  --   "roobert/tailwindcss-colorizer-cmp.nvim",
  --   config = function()
  --     require("tailwindcss-colorizer-cmp").setup({
  --       color_square_width = 2,
  --     })
  --   end,
  -- },
})

local nvim_tree = with_dependencies({
  "nvim-tree/nvim-tree.lua",
  config = l("tree"),
  keys = {
    { "<F1>", "<ESC>:NvimTreeToggle<CR>", mode = { "n", "x", "i" } },
    { "<F1>", "<CMD>NvimTreeToggle<CR>", mode = { "t" } },
    { "<space>af", "<CMD>NvimTreeFindFile!<CR><CMD>NvimTreeOpen<CR>", mode = { "n" } },
  },
}, { { "nvim-tree/nvim-web-devicons" } })

local comment = with_dependencies(
  { "numToStr/Comment.nvim", config = l("comment"), keys = { { "gc", mode = { "n", "x" } } } },
  { { "JoosepAlviste/nvim-ts-context-commentstring" } }
)

vim.g.polyglot_disabled = { "autoindent", "sensible" }

vim.g.VM_maps = {
  ["Select Cursor Down"] = "L",
  ["Select Cursor Up"] = "K",
}

local plugins = {
  lspconfig,
  nvim_tree,
  cmp,
  comment,
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    config = l("luasnip"),
    dependencies = {
      { "rafamadriz/friendly-snippets" },
    },
  },
  {
    "stevearc/dressing.nvim",
    opts = {
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
  { "kylechui/nvim-surround", config = true },
  { "nvim-lua/plenary.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
  { "jose-elias-alvarez/null-ls.nvim", config = l("null-ls") },
  {
    "nvim-telescope/telescope.nvim",
    config = l("telescope"),
    dependencies = {
      { "mbbill/undotree", keys = {
        { "<F3>", "<CMD>UndotreeToggle<CR>", desc = "toggle undo tree" },
      } },
    },
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
    opts = { auto_resize_height = false, func_map = { open = "o", openc = "<CR>" } },
    ft = "qf",
  },
  {
    "matbme/JABS.nvim",
    opts = {
      position = { "center", "center" },
      relative = "editor",
      width = 80,
      height = 20,
      border = "rounded",
      sort_mru = true,
      split_filename = true,
      split_filename_path_width = 50,
      preview_position = "right",
      preview = { width = 40, height = 60, border = "single" },
      keymap = { close = "d", jump = "<cr>", h_split = "v", v_split = "s" },
      symbols = {
        current = "C",
        split = "S",
        alternate = "A",
        hidden = "H",
        locked = "L",
        ro = "R",
        edited = "E",
        terminal = "T",
        default_file = "D",
        terminal_symbol = ">_",
      },
      highlight = {
        current = "StatusLine",
        hidden = "ModeMsg",
        split = "WarningMsg",
        alternate = "ModeMsg",
      },
    },
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
    keys = { { "<F2>", jabs_toggle, mode = { "n", "x", "i", "t" }, desc = "toggle buffer explorer" } },
  },
  { "mg979/vim-visual-multi", keys = { "L", "K", { "<C-n>", mode = { "n", "x" } } } },
}

if not config.minimal then
  plugins = F.concat(plugins, {
    {
      "johmsalas/text-case.nvim",
      config = l("text-case"),
      keys = { "<space>ac" },
    },
    {
      "nvim-lualine/lualine.nvim",
      config = l("lualine"),
      dependencies = {
        { "SmiteshP/nvim-navic" },
        { "nvim-tree/nvim-web-devicons" },
        {
          "linrongbin16/lsp-progress.nvim",
          dependencies = { "nvim-tree/nvim-web-devicons" },
          opts = {
            spinner = { "⣷", "⣯", "⣟", "⡿", "⢿", "⣻", "⣽", "⣾" },
            spin_update_time = 100,
            decay = 100,
          },
        },
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
    { "rhysd/clever-f.vim" },
    { "windwp/nvim-autopairs", config = true, event = "InsertEnter" },
    { "NvChad/nvim-colorizer.lua" },
    { "saecki/crates.nvim", config = true, event = { "BufNewFile Cargo.toml", "BufRead Cargo.toml" } },
    {
      "nvim-treesitter/nvim-treesitter",
      config = l("treesitter"),
      dependencies = {
        { "mrjones2014/nvim-ts-rainbow" },
        -- { "HiPhish/nvim-ts-rainbow2" },
        { "m-demare/hlargs.nvim" },
        { "nvim-treesitter/nvim-treesitter-textobjects" },
        { "nvim-treesitter/nvim-treesitter-context" },
        { "windwp/nvim-ts-autotag" },
      },
    },
    {
      "Wansmer/treesj",
      opts = {
        use_default_keymaps = false,
        check_syntax_error = true,
        cursor_behavior = "hold",
        notify = true,
        max_join_length = 100000,
      },
      keys = { { "Y", creq("treesj").toggle(), mode = { "n", "x" }, desc = "toggle split join" } },
    },
    {
      "mfussenegger/nvim-dap",
      config = l("dap"),
      dependencies = {
        { "rcarriga/nvim-dap-ui" },
        { "theHamsta/nvim-dap-virtual-text" },
        { "mfussenegger/nvim-dap-python" },
      },
    },
    {
      "simrat39/symbols-outline.nvim",
      opts = { width = 40 },
      keys = { { "<space>as", "<ESC>:SymbolsOutline<CR>", desc = "toggle symbols outline" } },
    },
    { "lervag/vimtex", config = l("vimtex"), ft = "tex" },
    { url = "https://gitlab.com/yorickpeterse/nvim-pqf", config = true },
    {
      "folke/todo-comments.nvim",
      opts = {
        search = {
          command = "rg",
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--max-filesize=1M",
          },
        },
      },
      lazy = false,
      keys = { { "<space>at", "<CMD>TodoQuickFix<CR>", desc = "show todos in quickfix" } },
    },
    {
      "ziontee113/icon-picker.nvim",
      config = true,
      keys = { { "<space>ai", "<CMD>PickIcons<CR>", desc = "open icon picker" } },
    },
    { "ggandor/leap.nvim", config = creq("leap").set_default_keymaps(), keys = { "s", "S" } },
    { "nmac427/guess-indent.nvim", opts = {} },
    { "sheerun/vim-polyglot" },
    { "anuvyklack/hydra.nvim" },
    { "mfussenegger/nvim-lint", config = l("lint"), keys = { "<space>al", "<space>ö" } },
    {
      "iamcco/markdown-preview.nvim",
      build = "cd app && npm install",
      lazy = false,
      config = function()
        vim.cmd([[
          function OpenMarkdown(url)
            echo a:url
            if empty($SSH_TTY)
              call system($BROWSER .. " " .. a:url)
            endif
          endfunction
        ]])
        vim.g.mkdp_browserfunc = "OpenMarkdown"
        if os.getenv("SSH_TTY") then
          vim.g.mkdp_port = 8100
        end
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
