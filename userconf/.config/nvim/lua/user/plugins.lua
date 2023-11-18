local F = require("user.functional")

local config = require("user.config")

local illuminate_denylist = {
  "",
  "NvimTree",
  "Trouble",
  "fugitiveblame",
  "help",
  "json",
  "lsputil_codeaction_list",
  "markdown",
  "packer",
  "qf",
  "vista",
  "yaml",
  "TelescopePrompt",
}

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
        "loader for '" .. plugin_name .. "' failed (used: '" .. src .. "')" .. "\n" .. message,
        vim.log.levels.INFO
      )
    end
  end
end

local function with_dependencies(plugin, optional_dependencies)
  if not config.minimal then
    plugin.dependencies = plugin.dependencies or {}
    plugin.dependencies = F.concat(plugin.dependencies, optional_dependencies)
  end
  return plugin
end

local lspconfig = with_dependencies({
  "neovim/nvim-lspconfig",
  config = l("lspconfig"),
  dependencies = {
    { "williamboman/mason.nvim", opts = { ui = { border = config.border } }, config = true },
    { "williamboman/mason-lspconfig.nvim" },
  },
}, {
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  {
    "azabiong/vim-highlighter",
    keys = {
      { "f<CR>", "<CMD>call highlighter#Command('+')<CR>", mode = "n", silent = true },
      { "f<CR>", ":<C-U>call highlighter#Command('+x')<CR>", mode = "x", silent = true },
      { "dh", "<CMD>call highlighter#Command('-')<CR>", mode = "n", silent = true },
      { "dah", "<CMD>call highlighter#Command('clear')<CR>", mode = "n", silent = true },
      { "t<CR>", "<CMD>call highlighter#Command('+%')<CR>", mode = "n", silent = true },
      { "t<CR>", ":<C-U>call highlighter#Command('+x%')<CR>", mode = "x", silent = true },
    },
    init = function()
      vim.g.HiMapKeys = 0
    end,
  },
  { "b0o/schemastore.nvim" },
  {
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate").configure({
        providers = { "lsp" },
        filetypes_denylist = illuminate_denylist,
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
  { "FelipeLema/cmp-async-path" },
  { "hrsh7th/cmp-nvim-lua" },
  { "andersevenrud/cmp-tmux" },
})

local nvim_tree = with_dependencies({
  "nvim-tree/nvim-tree.lua",
  config = l("tree"),
  lazy = false,
  keys = {
    { "<F1>", "<ESC>:NvimTreeToggle<CR>", mode = { "n", "x", "i" } },
    { "<F1>", "<CMD>NvimTreeToggle<CR>", mode = { "t" } },
  },
}, { { "nvim-tree/nvim-web-devicons" } })

local comment = with_dependencies(
  { "numToStr/Comment.nvim", config = l("comment"), keys = { { "gc", mode = { "n", "x" } } } },
  { { "JoosepAlviste/nvim-ts-context-commentstring" } }
)

vim.g.VM_maps = {
  ["Select Cursor Down"] = "L",
  ["Select Cursor Up"] = "K",
}

local plugins = {
  { "folke/lazy.nvim" },
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
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = l("conform"),
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
      {
        "<space>/",
        "<CMD>Telescope current_buffer_fuzzy_find<CR>",
        mode = { "n", "x" },
        desc = "fuzzy find in current buffer",
      },
      { "<F2>", "<CMD>Telescope custom_buffers<CR>", mode = { "n", "x", "t", "i" }, desc = "toggle buffer explorer" },
      { "<space>h", "<CMD>Telescope help_tags<CR>", mode = { "n", "x" }, desc = "search help tags" },
      { "<space>,,", "<CMD>Telescope resume<CR>", mode = { "n", "x" }, desc = "resume last search" },
      { "<space>,h", "<CMD>Telescope highlights<CR>", mode = { "n", "x" }, desc = "search highlights" },
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
    opts = {
      auto_resize_height = false,
      func_map = { open = "o", openc = "<CR>" },
      preview = {
        border = config.border,
        winblend = 0,
      },
    },
    ft = "qf",
  },
  -- { "smoka7/multicursors.nvim", event = "VeryLazy", opts = {}, cmd = {"MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor"}, keys = {{mode = {"v", "n"}, "<Leader>k", "<cmd>MCstart<cr>", desc = "Create a selection for selected text or word under the cursor"}} },
  -- { "brenton-leighton/multiple-cursors.nvim" },
  { "mg979/vim-visual-multi", keys = { "L", "K", { "<C-n>", mode = { "n", "x" } } } },
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
          "j-hui/fidget.nvim",
          event = "LspAttach",
          opts = {
            progress = {
              suppress_on_insert = false,
              ignore_done_already = true,
              display = {
                done_style = "FidgetDone",
                group_style = "FidgetGroup",
                progress_style = "FidgetProgress",
              },
            },
            notification = {
              window = {
                normal_hl = "FidgetNormal",
                winblend = 100,
                x_padding = 0,
                align_bottom = false,
              },
            },
          },
        },
        -- {
        --   "linrongbin16/lsp-progress.nvim",
        --   dependencies = { "nvim-tree/nvim-web-devicons" },
        --   opts = {
        --     spinner = { "⣷", "⣯", "⣟", "⡿", "⢿", "⣻", "⣽", "⣾" },
        --     spin_update_time = 20,
        --     decay = 700,
        --   },
        -- },
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
    {
      "rhysd/clever-f.vim",
      event = "VeryLazy",
      init = function()
        vim.g.clever_f_across_no_line = 1
        vim.g.clever_f_smart_case = 1
        vim.g.clever_f_mark_direct = 1
      end,
    },
    {
      "altermo/ultimate-autopair.nvim",
      event = { "InsertEnter", "CmdlineEnter" },
      branch = "v0.6",
      opts = { tabout = { enable = true }, cmap = false },
    },
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
        { "Wansmer/treesj", config = l("treesj") },
        {
          "Wansmer/sibling-swap.nvim",
          config = function()
            local sibling_swap = require("sibling-swap")
            sibling_swap.setup({ use_default_keymaps = false })
            vim.keymap.set("n", "R", sibling_swap.swap_with_left)
            vim.keymap.set("n", "U", sibling_swap.swap_with_right)
          end,
        },
      },
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
    {
      "lervag/vimtex",
      init = function()
        vim.g.vimtex_imaps_enabled = 0
        vim.g.vimtex_complete_enabled = 0
        vim.g.vimtex_matchparen_enabled = 0
        vim.g.vimtex_syntax_enabled = 0
        vim.g.vimtex_syntax_conceal_disable = 1
        vim.g.vimtex_view_method = "zathura"
        vim.g.vimtex_view_skim_reading_bar = 1
        vim.g.vimtex_quickfix_mode = 2
        vim.g.vimtex_quickfix_open_on_warning = 0
        vim.g.tex_flavor = "latex"
        vim.g.tex_conceal = "abdmg"
      end,
      ft = "tex",
    },
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
          mode = { "n", "o" },
          function()
            require("flash").treesitter()
          end,
          desc = "Flash Treesitter",
        },
        -- {
        --   "<C-s>",
        --   mode = { "x" },
        --   function()
        --     require("flash").treesitter()
        --   end,
        --   desc = "Flash Treesitter",
        -- },
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
        -- {
        --   "<c-s>",
        --   mode = { "c" },
        --   function()
        --     require("flash").toggle()
        --   end,
        --   desc = "Toggle Flash Search",
        -- },
      },
    },
    { "nmac427/guess-indent.nvim", opts = {} },
    { "anuvyklack/hydra.nvim", lazy = true },
    { "mfussenegger/nvim-lint", config = l("lint"), keys = { "<space>al", "<space>ö" } },
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      ft = { "markdown" },
      build = function()
        vim.fn["mkdp#util#install"]()
      end,
      init = function()
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
      keys = { { "<space>tb", "<CMD>ToggleBlame window<CR>", desc = "toggle blamer" } },
    },
    { "echasnovski/mini.nvim", version = false },
  })
end

require("lazy").setup(plugins, {
  defaults = {
    lazy = false,
  },
  checker = {
    enabled = false,
  },
  ui = {
    border = config.border,
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
