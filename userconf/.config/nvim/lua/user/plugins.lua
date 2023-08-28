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

local luasnip = {
  "L3MON4D3/LuaSnip",
  config = l("luasnip"),
  dependencies = {
    { "rafamadriz/friendly-snippets" },
  },
}

if not config.minimal then
  luasnip.build = "make install_jsregexp"
end

local cmp = with_dependencies({
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  config = l("cmp"),
  dependencies = {
    { "saadparwaiz1/cmp_luasnip" },
    { "hrsh7th/cmp-nvim-lsp" },
    luasnip,
  },
}, {
  { "onsails/lspkind.nvim" },
  { "hrsh7th/cmp-buffer" },
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
  lazy = false,
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
    "stevearc/dressing.nvim",
    event = "VeryLazy",
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
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = true,
  },
  { "nvim-lua/plenary.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = l("null-ls"),
  },
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
  {
    "mg979/vim-visual-multi",
    keys = { "L", "K", { "<C-n>", mode = { "n", "x" } } },
  },
  { "mbbill/undotree", keys = { { "<F3>", "<CMD>UndotreeToggle<CR>", desc = "toggle undo tree" } } },
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
    { "rhysd/clever-f.vim", event = "VeryLazy" },
    { "windwp/nvim-autopairs", config = true, event = "InsertEnter" },
    { "NvChad/nvim-colorizer.lua" },
    { "saecki/crates.nvim", config = true, event = { "BufNewFile Cargo.toml", "BufRead Cargo.toml" } },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      event = { "BufReadPost", "BufNewFile" },
      config = l("treesitter"),
      dependencies = {
        {
          "https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
          config = function()
            vim.g.rainbow_delimiters = {
              strategy = {
                [""] = function()
                  local rb = require("rainbow-delimiters")
                  return vim.fn.line("$") > 1000 and rb.strategy["noop"] or rb.strategy["global"]
                end,
              },
            }
          end,
        },
        { "m-demare/hlargs.nvim" },
        { "nvim-treesitter/nvim-treesitter-textobjects" },
        { "nvim-treesitter/nvim-treesitter-context" },
        { "windwp/nvim-ts-autotag" },
        {
          "Wansmer/sibling-swap.nvim",
          config = function()
            local sibling_swap = require("sibling-swap")
            sibling_swap.setup({ use_default_keymaps = false })
            vim.keymap.set('n', "R", sibling_swap.swap_with_left)
            vim.keymap.set('n', "U", sibling_swap.swap_with_right)
          end,
        },
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
      event = "VeryLazy",
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
    {
      "folke/todo-comments.nvim",
      event = { "BufReadPost", "BufNewFile" },
      opts = {
        keywords = {
          FIX = { icon = config.icons.Fix, color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
          TODO = { icon = config.icons.Todo, color = "info" },
          HACK = { icon = config.icons.Hack, color = "warning" },
          WARN = { icon = config.icons.Warn, color = "warning", alt = { "WARNING", "XXX" } },
          PERF = { icon = config.icons.Perf, color = "warning", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = config.icons.Note, color = "hint", alt = { "INFO" } },
          TEST = { icon = config.icons.Test, color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        },
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
      keys = { { "<space>at", "<CMD>TodoQuickFix<CR>", desc = "show todos in quickfix" } },
    },
    {
      "ziontee113/icon-picker.nvim",
      config = true,
      keys = { { "<space>ai", "<CMD>IconPickerYank emoji nerd_font_v3<CR>", desc = "open icon picker" } },
    },
    {
      "folke/flash.nvim",
      event = "VeryLazy",
      opts = {
        highlight = {
          priority = 9999,
        },
        modes = {
          char = { enabled = false },
          search = { enabled = false },
        },
      },
      keys = {
        {
          "s",
          mode = { "n", "x", "o" },
          function()
            require("flash").jump()
          end,
          desc = "Flash",
        },
        {
          "S",
          mode = { "n", "o", "x" },
          function()
            require("flash").treesitter()
          end,
          desc = "Flash Treesitter",
        },
        {
          "r",
          mode = "o",
          function()
            require("flash").remote()
          end,
          desc = "Remote Flash",
        },
        {
          "R",
          mode = { "o", "x" },
          function()
            require("flash").treesitter_search()
          end,
          desc = "Treesitter Search",
        },
        {
          "<c-s>",
          mode = { "c" },
          function()
            require("flash").toggle()
          end,
          desc = "Toggle Flash Search",
        },
      },
    },
    { "nmac427/guess-indent.nvim", opts = {} },
    { "sheerun/vim-polyglot" },
    { "anuvyklack/hydra.nvim", lazy = true },
    { "mfussenegger/nvim-lint", config = l("lint"), keys = { "<space>al", "<space>ö" } },
    {
      "iamcco/markdown-preview.nvim",
      event = { "BufReadPost", "BufNewFile" },
      build = "cd app && npm install",
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
    {
      "FabijanZulj/blame.nvim",
      keys = { { "<space>gb", "<CMD>ToggleBlame window<CR>", desc = "toggle blamer" } },
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
        "2html_plugin",
        "bugreport",
        "compiler",
        "ftplugin",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "matchit",
        "matchparen",
        "netrw",
        "netrwFileHandlers",
        "netrwPlugin",
        "netrwSettings",
        "optwin",
        "rplugin",
        "rrhelper",
        "shada",
        "spellfile_plugin",
        "synmenu",
        "syntax",
        "syntax_completion",
        "tar",
        "tarPlugin",
        "tohtml",
        "tutor",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
      },
    },
  },
})

-- local unused = {
--   { "CRAG666/code_runner.nvim" },
--   { "pwntester/octo.nvim" },
--   { "NTBBloodbath/rest.nvim" },
-- }

vim.keymap.set("n", "<space>ps", "<ESC>:Lazy sync<CR>", { desc = "install, clean, and update plugins" })
