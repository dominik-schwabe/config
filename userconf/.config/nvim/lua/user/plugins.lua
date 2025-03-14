local F = require("user.functional")

local config = require("user.config")

local function desc(opts, description)
  return F.extend(opts, { desc = description })
end

local function bind_select_action(entries, opts)
  opts = opts or {}
  local buffer = opts.buffer
  local on_select = opts.on_select
  local format_item = opts.format_item
  local map_opts = { noremap = true, silent = true, buffer = buffer }
  vim.keymap.set({ "n", "x" }, "<space>ch", function()
    vim.ui.select(entries, {
      prompt = "actions:",
      format_item = format_item,
    }, function(choice)
      if choice then
        on_select(choice)
      end
    end)
  end, desc(map_opts, "select actions"))
end

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
  {
    "azabiong/vim-highlighter",
    keys = {
      { "<space>ha", "<CMD>call highlighter#Command('+')<CR>", mode = "n", silent = true },
      { "<space>ha", ":<C-U>call highlighter#Command('+x')<CR>", mode = "x", silent = true },
      { "dh", "<CMD>call highlighter#Command('-')<CR>", mode = "n", silent = true },
      { "dah", "<CMD>call highlighter#Command('clear')<CR>", mode = "n", silent = true },
      { "<space>hi", "<CMD>call highlighter#Command('+%')<CR>", mode = "n", silent = true },
      { "<space>hi", ":<C-U>call highlighter#Command('+x%')<CR>", mode = "x", silent = true },
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
  {
    "mrcjkb/rustaceanvim",
    ft = { "rust" },
    init = function()
      vim.g.rustaceanvim = {
        tools = {
          float_win_config = {
            border = config.border,
          },
        },
        server = {
          on_attach = function(client, bufnr)
            local map_opts = { noremap = true, silent = true, buffer = bufnr }
            local rcb = F.f(vim.cmd.RustLsp)
            vim.keymap.set("n", "gh", rcb({ "hover", "actions" }), desc(map_opts, "rust hover actions"))
            bind_select_action({
              { "debuggables" },
              { "debuggables", "last" },
              { "runnables" },
              { "runnables", "last" },
              { "explainError" },
              { "expandMacro" },
              { "rebuildProcMacros" },
              { "openCargo" },
              { "view", "hir" },
              { "view", "mir" },
            }, {
              buffer = bufnr,
              on_select = function(choice)
                vim.cmd.RustLsp(F.copy(choice))
              end,
              format_item = function(item)
                return table.concat(item, " ")
              end,
            })
          end,
          settings = function(project_root)
            local ra = require("rustaceanvim.config.server")
            local default_settings = require("rustaceanvim.config.internal").server.default_settings
            local settings = ra.load_rust_analyzer_settings(project_root, {
              settings_file_pattern = "rust-analyzer.json",
            })
            if settings == default_settings then
              settings = { ["rust-analyzer"] = config.lsp_configs.rust_analyzer or {} }
            end
            return settings
          end,
        },
        dap = {},
      }
    end,
  },
})

local luasnip = {
  "L3MON4D3/LuaSnip",
  config = l("luasnip"),
  dependencies = {
    { "rafamadriz/friendly-snippets" },
    -- { "mireq/luasnip-snippets" },
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

local comment = with_dependencies({
  "numToStr/Comment.nvim",
  config = function()
    local opts = {
      padding = true,
      sticky = true,
      ignore = "^%s*$",
      mappings = { basic = true, extra = true },
    }
    F.load("ts_context_commentstring.integrations.comment_nvim", function(ttscc)
      opts.pre_hook = ttscc.create_pre_hook()
    end)
    require("Comment").setup(opts)
  end,
  keys = { { "gc", mode = { "n", "x" } } },
}, {
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    init = function()
      vim.g.skip_ts_context_commentstring_module = true
    end,
  },
})

vim.g.VM_maps = {
  ["Select Cursor Down"] = "L",
  ["Select Cursor Up"] = "K",
}

local plugins = F.concat({
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
      { "<space>,,", "<CMD>Telescope resume<CR>", mode = { "n", "x" }, desc = "resume last search" },
      { "<space>,h", "<CMD>Telescope help_tags<CR>", mode = { "n", "x" }, desc = "search help tags" },
      { "<space>,c", "<CMD>Telescope highlights<CR>", mode = { "n", "x" }, desc = "search highlights" },
      { "<space>,k", "<CMD>Telescope keymaps<CR>", mode = { "n", "x" }, desc = "search keymaps" },
      { "<space>,j", "<CMD>Telescope jumplist<CR>", mode = { "n", "x" }, desc = "search jumplist" },
      { "<space>,y", "<CMD>Telescope yank_history<CR>", mode = { "n", "x" }, desc = "search yank history" },
      { "<space>,m", "<CMD>Telescope macro_history<CR>", mode = { "n", "x" }, desc = "search macro history" },
      { "<space>,d", "<CMD>Telescope diffsplit<CR>", mode = { "n", "x" }, desc = "search diffsplit commits" },
      { "<space>,s", "<CMD>Telescope git_status<CR>", mode = { "n", "x" }, desc = "search changed files" },
    },
  },
  {
    "kevinhwang91/nvim-bqf",
    opts = {
      auto_resize_height = false,
      func_map = {
        open = "o",
        openc = "<CR>",
        nextfile = "",
      },
      preview = {
        border = config.border,
        winblend = 0,
      },
    },
    ft = "qf",
  },
  {
    "stevearc/quicker.nvim",
    ft = "qf",
    opts = {},
  },
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")

      mc.setup()

      local set = vim.keymap.set

      -- local line_add_cursor = F.f(mc.lineAddCursor)
      -- local line_skip_cursor = F.f(mc.lineSkipCursor)
      local match_add_cursor = F.f(mc.matchAddCursor)
      local match_skip_cursor = F.f(mc.matchSkipCursor)
      local transpose_cursor = F.f(mc.transposeCursors)

      -- set({ "n", "v" }, "<up>", line_add_cursor(-1))
      -- set({ "n", "v" }, "<down>", line_add_cursor(1))
      -- set({ "n", "v" }, "<leader><up>", line_skip_cursor(-1))
      -- set({ "n", "v" }, "<leader><down>", line_skip_cursor(1))

      set({ "n", "v" }, "<C-N>", match_add_cursor(1))
      set({ "n", "v" }, "<space>n", match_skip_cursor(-1))
      set({ "n", "v" }, "<space>N", match_skip_cursor(1))

      set({ "n", "v" }, "<space>ma", mc.matchAllAddCursors)

      set({ "n", "v" }, "<space>j", mc.nextCursor)
      set({ "n", "v" }, "<space>k", mc.prevCursor)

      -- Delete the main cursor.
      set({ "n", "v" }, "<leader>x", mc.deleteCursor)

      -- Easy way to add and remove cursors using the main cursor.
      set({ "n", "v" }, "<c-q>", mc.toggleCursor)

      -- Clone every cursor and disable the originals.
      set({ "n", "v" }, "<leader><c-q>", mc.duplicateCursors)

      set("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        elseif mc.hasCursors() then
          mc.clearCursors()
        else
          -- Default <esc> handler.
        end
      end)

      -- bring back cursors if you accidentally clear them
      set("n", "<space>mm", mc.restoreCursors)

      -- Align cursor columns.
      set("n", "<space>ma", mc.alignCursors)

      -- Split visual selections by regex.
      set("v", "<space>mr", mc.splitCursors)

      -- Append/insert for each line of visual selections.
      set("v", "I", mc.insertVisual)
      set("v", "A", mc.appendVisual)

      -- match new cursors within visual selections by regex.
      set("v", "M", mc.matchCursors)

      -- Rotate visual selection contents.
      set("v", "<space>mt", transpose_cursor(1))
      set("v", "<leader>T", transpose_cursor(-1))

      -- Jumplist support
      set({ "v", "n" }, "<c-i>", mc.jumpForward)
      set({ "v", "n" }, "<c-o>", mc.jumpBackward)
    end,
  },
  { "mbbill/undotree", keys = { { "<F3>", "<CMD>UndotreeToggle<CR>", desc = "toggle undo tree" } } },
  -- {
  --   "jiaoshijie/undotree",
  --   dependencies = "nvim-lua/plenary.nvim",
  --   config = true,
  --   keys = {
  --     {
  --       "<F3>",
  --       function()
  --         require("undotree").toggle()
  --       end,
  --       desc = "toggle undo tree",
  --     },
  --   },
  -- },
  {
    dir = config.custom_plugin_path .. "/rooter",
    config = function()
      local rooter = require("rooter")
      rooter.setup({
        path_replacements = function()
          return {
            [vim.env.HOME] = "~/",
            [vim.env.HOME .. "/.local/share/mise/installs"] = "mise://",
            [vim.env.HOME .. "/.asdf"] = "asdf://",
          }
        end,
      })
      vim.keymap.set("n", "<space>,w", function()
        rooter.pick_root({
          callback = function(root)
            F.load("nvim-tree.api", function(tree_api)
              tree_api.tree.open({ path = root })
            end)
          end,
        })
      end, { desc = "pick a root" })
    end,
  },
  {
    dir = config.custom_plugin_path .. "/repl",
    config = function()
      require("repl").setup({
        preferred = config.repls,
        listed = false,
        debug = false,
        ensure_win = true,
      })

      local send = require("repl.send")
      local window = require("repl.window")
      local repls = F.keys(require("repl.repls").repls)

      local function mark_jump()
        vim.cmd("mark '")
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserRepl", {}),
        callback = function(args)
          local bufopt = vim.bo[args.buf]
          if F.contains(repls, bufopt.filetype) then
            local map_opt = { buffer = args.buf }
            vim.keymap.set("n", "<C-space>", F.chain(mark_jump, send.paragraph), desc(map_opt, "send paragraph"))
            vim.keymap.set("n", "<CR>", F.f(send.line_next)(), desc(map_opt, "send line and go next"))
            vim.keymap.set("x", "<CR>", F.f(send.visual)(), desc(map_opt, "send visual"))
            vim.keymap.set("n", "=", F.f(send.line)(), desc(map_opt, "send line and stay"))
            vim.keymap.set("n", "<leader><space>", F.f(send.buffer)(), desc(map_opt, "send buffer"))
            vim.keymap.set("n", "<leader>m", F.f(send.motion)(), desc(map_opt, "send motion"))
            vim.keymap.set("n", "<leader>M", F.f(send.newline)(), desc(map_opt, "send newline"))
            vim.keymap.set({ "n", "i", "t" }, "<F4>", F.f(window.toggle_repl)(), desc(map_opt, "toggle repl"))
          end
        end,
      })
    end,
  },
  { dir = config.custom_plugin_path .. "/monokai-rainbow" },
  {
    dir = config.custom_plugin_path .. "/fullscreen",
    opts = {},
    cmd = { "ToggleFullscreen" },
    keys = {
      { "<F24>", "<CMD>ToggleFullscreen<CR>", mode = { "n", "x", "t" }, desc = "toggle fullscreen" },
      { "<F24>", "<ESC>:ToggleFullscreen<CR>", mode = { "i" }, desc = "toggle fullscreen" },
    },
  },
})

if not config.minimal then
  plugins = F.concat(plugins, {
    {
      "johmsalas/text-case.nvim",
      config = l("text-case"),
      keys = { "<space>cc" },
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
                align = "top",
              },
            },
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
    {
      "altermo/ultimate-autopair.nvim",
      event = { "InsertEnter", "CmdlineEnter" },
      branch = "v0.6",
      opts = {
        tabout = { enable = true },
        cmap = false,
        config_internal_pairs = {
          {
            "'",
            "'",
            multiline = false,
            surround = true,
            nft = { "xdata", "xdatal" },
            cond = function(fn)
              return not fn.in_node({ "bounded_type", "type_parameters" })
            end,
          },
          { "`", "`", nft = { "python", "xdata", "xdatal" } },
        },
      },
    },
    {
      "catgoose/nvim-colorizer.lua",
      opts = {
        filetypes = { "*", "!cmp_menu" },
        user_default_options = {
          names = false,
          rgb_fn = true,
          hsl_fn = true,
          tailwind = true,
        },
      },
    },
    {
      "saecki/crates.nvim",
      config = true,
      opts = {
        popup = {
          border = config.border,
          hide_on_select = true,
          show_version_date = true,
          max_height = 25,
        },
        completion = {
          cmp = {
            enabled = true,
          },
        },
        on_attach = function(bufnr)
          bind_select_action({
            { "Dependencies", "show_dependencies_popup", true },
            { "Update Crate", "update_crate", false },
            { "Update All", "update_all_crates", false },
            { "Upgrade Crate", "upgrade_crate", false },
            { "Upgrade All", "upgrade_all_crates", false },
            { "Features", "show_features_popup", true },
          }, {
            buffer = bufnr,
            on_select = function(choice)
              local crates = require("crates")
              crates[choice[2]]()
              if choice[3] then
                crates.focus_popup()
              end
            end,
            format_item = function(item)
              return item[1]
            end,
          })
        end,
      },
      event = { "BufNewFile Cargo.toml", "BufRead Cargo.toml" },
    },
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
      keys = { { "<space>os", "<ESC>:SymbolsOutline<CR>", desc = "toggle symbols outline" } },
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
      keys = { { "<space>ot", "<CMD>TodoQuickFix<CR>", desc = "show todos in quickfix" } },
    },
    {
      "ziontee113/icon-picker.nvim",
      config = true,
      keys = { { "<space>,i", "<CMD>IconPickerYank emoji nerd_font_v3<CR>", desc = "open icon picker" } },
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
    { "nvimtools/hydra.nvim", lazy = true },
    { "mfussenegger/nvim-lint", config = l("lint"), keys = { "<space>cl", "dal" } },
    -- {
    --   "OXY2DEV/markview.nvim",
    --   lazy = false,
    --   opts = { preview = { enable = false, enable_hybrid_mode = false } },
    --   keys = { { "<space>tm", "<CMD>Markview splitToggle<CR>", desc = "toggle markview markdown preview" } },
    -- },
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
              call system("xdg-open " .. a:url)
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
      keys = { { "<space>tM", "<CMD>MarkdownPreviewToggle<CR>", desc = "toggle markdown preview" } },
    },
    {
      "FabijanZulj/blame.nvim",
      opts = {},
      keys = { { "<space>tb", "<CMD>BlameToggle virtual<CR>", desc = "toggle blamer" } },
    },
    { "echasnovski/mini.nvim", version = false },
    { "jbyuki/venn.nvim", config = l("venn") },
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

vim.keymap.set("n", "<space>ol", "<ESC>:Lazy<CR>", { desc = "install, clean, and update plugins" })
