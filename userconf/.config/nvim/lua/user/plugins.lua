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

local disabled_plugins = {
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
}

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

vim.g.VM_maps = {
  ["Select Cursor Down"] = "L",
  ["Select Cursor Up"] = "K",
}

local plugins = F.concat({
  { "folke/lazy.nvim" },
  { "neovim/nvim-lspconfig", config = l("lspconfig") },
  { "mason-org/mason.nvim", opts = { ui = { border = config.border } } },
  { "mason-org/mason-lspconfig.nvim" },
  {
    "nvim-tree/nvim-tree.lua",
    config = l("tree"),
    lazy = false,
    keys = {
      { "<F1>", "<ESC>:NvimTreeToggle<CR>", mode = { "n", "x", "i" } },
      { "<F1>", "<CMD>NvimTreeToggle<CR>", mode = { "t" } },
    },
  },
  { "nvim-tree/nvim-web-devicons" },
  { "saghen/blink.cmp", version = "1.*", config = l("blink") },
  { "mgalliou/blink-cmp-tmux" },
  { "rafamadriz/friendly-snippets" },
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.comment").setup({
        options = {
          custom_commentstring = function()
            return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
          end,
          ignore_blank_line = true,
        },
      })
      require("mini.icons").setup()
    end,
  },
  { "JoosepAlviste/nvim-ts-context-commentstring" },
  -- { "folke/snacks.nvim" },
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
  { "kylechui/nvim-surround", config = true },
  { "nvim-lua/plenary.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
  { "stevearc/conform.nvim", config = l("conform") },
  -- { "dmtrKovalenko/fff.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    config = l("telescope"),
    cmd = "Telescope",
    keys = {
      {
        "<C-p>",
        function()
          require("telescope.builtin").find_files({ no_ignore = require("user.utils").is_git_ignored(vim.fn.getcwd()) })
        end,
        mode = { "n", "x", "i" },
        desc = "find files",
      },
      {
        "_",
        function()
          local args = {}
          if require("user.utils").is_git_ignored(vim.fn.getcwd()) then
            args[#args + 1] = "--no-ignore"
          end
          require("telescope.builtin").live_grep({ additional_args = args })
        end,
        mode = { "n", "x" },
        desc = "live grep",
      },
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
        openc = "<CR>",
        vsplit = "s",
        prevhist = "<",
        nexthist = ">",
        open = "",
        tab = "",
        tabb = "",
        tabc = "",
        drop = "",
        split = "",
        nextfile = "",
        tabdrop = "",
        ptogglemode = "",
        ptoggleitem = "",
        ptoggleauto = "",
        pscrollup = "",
        pscrolldown = "",
        pscrollorig = "",
        prevfile = "",
        lastleave = "",
        stoggleup = "",
        stoggledown = "",
        stogglevm = "",
        stogglebuf = "",
        sclear = "",
        filter = "",
        filterr = "",
        fzffilter = "",
      },
      preview = {
        border = config.border,
        winblend = 0,
      },
    },
    ft = "qf",
  },
  { "stevearc/quicker.nvim", ft = "qf", opts = {} },
  {
    "jake-stewart/multicursor.nvim",
    config = function()
      local mc = require("multicursor-nvim")

      mc.setup()

      local set = vim.keymap.set

      local match_add_cursor = F.f(mc.matchAddCursor)
      local match_skip_cursor = F.f(mc.matchSkipCursor)
      local transpose_cursor = F.f(mc.transposeCursors)

      set({ "n", "v" }, "<C-N>", match_add_cursor(1))
      set({ "n", "v" }, "<space>n", match_skip_cursor(-1))
      set({ "n", "v" }, "<space>N", match_skip_cursor(1))

      set({ "n", "v" }, "<space>ma", mc.matchAllAddCursors)

      set({ "n", "v" }, "<space>j", mc.nextCursor)
      set({ "n", "v" }, "<space>k", mc.prevCursor)

      set({ "n", "v" }, "<leader>x", mc.deleteCursor)

      local TERM_CODES = require("multicursor-nvim.term-codes")

      set({ "v" }, "<tab>", function()
        local mode = vim.fn.mode()
        mc.action(function(ctx)
          ctx:forEachCursor(function(cursor)
            cursor:splitVisualLines()
          end)
          ctx:forEachCursor(function(cursor)
            cursor:feedkeys(
              (cursor:atVisualStart() and "o" or "") .. "<esc>" .. (mode == TERM_CODES.CTRL_V and "" or "$"),
              { keycodes = true }
            )
          end)
        end)
      end)

      set({ "n", "v" }, "<leader><c-q>", mc.duplicateCursors)

      set("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        elseif mc.hasCursors() then
          mc.clearCursors()
        end
      end)

      set("n", "<space>mm", mc.restoreCursors)

      set("n", "<space>ma", mc.alignCursors)

      set("v", "<space>mr", mc.splitCursors)

      set("v", "I", mc.insertVisual)
      set("v", "A", mc.appendVisual)

      set("v", "M", mc.matchCursors)

      set("v", "<space>mt", transpose_cursor(1))
      set("v", "<leader>T", transpose_cursor(-1))

      set({ "v", "n" }, "<c-i>", mc.jumpForward)
      set({ "v", "n" }, "<c-o>", mc.jumpBackward)
    end,
  },
  { "mbbill/undotree", keys = { { "<F3>", "<CMD>UndotreeToggle<CR>", desc = "toggle undo tree" } } },
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
      local repls = vim.tbl_keys(require("repl.repls").repls)

      local function mark_jump()
        vim.cmd("mark '")
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserRepl", {}),
        callback = function(args)
          local bufopt = vim.bo[args.buf]
          if vim.tbl_contains(repls, bufopt.filetype) then
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
    { "pmizio/typescript-tools.nvim", opts = {} },
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
    {
      "johmsalas/text-case.nvim",
      config = function()
        local textcase = require("textcase")
        require("hydra")({
          hint = [[
_<F9>_  : to-snake-case (LSP)
_<F10>_ : TO-CONSTANT-CASE (LSP)
_<F11>_ : toCamelCase (LSP)
_<F12>_ : ToPascalCase (LSP)
_<F5>_  : to-snake-case
_<F6>_  : TO-CONSTANT-CASE
_<F7>_  : toCamelCase
_<F8>_  : ToPascalCase
_<C-c>_ : exit
]],
          config = {
            color = "pink",
            invoke_on_body = true,
            hint = {
              position = "middle-right",
              float_opts = {
                border = config.border,
              },
            },
          },
          name = "textcase",
          mode = { "n", "x" },
          body = "<space>cc",
          heads = {
            { "<F5>", F.f(textcase.current_word)("to_snake_case"), { silent = true, nowait = true } },
            { "<F6>", F.f(textcase.current_word)("to_constant_case"), { silent = true, nowait = true } },
            { "<F7>", F.f(textcase.current_word)("to_camel_case"), { silent = true, nowait = true } },
            { "<F8>", F.f(textcase.current_word)("to_pascal_case"), { silent = true, nowait = true } },
            { "<F9>", F.f(textcase.lsp_rename)("to_snake_case"), { silent = true, nowait = true } },
            { "<F10>", F.f(textcase.lsp_rename)("to_constant_case"), { silent = true, nowait = true } },
            { "<F11>", F.f(textcase.lsp_rename)("to_camel_case"), { silent = true, nowait = true } },
            { "<F12>", F.f(textcase.lsp_rename)("to_pascal_case"), { silent = true, nowait = true } },
            { "<C-c>", nil, { exit = true, nowait = true } },
          },
        })
      end,
      keys = { "<space>cc" },
    },
    { "nvim-lualine/lualine.nvim", config = l("lualine") },
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
    {
      "monaqa/dial.nvim",
      config = function()
        local augend = require("dial.augend")
        require("dial.config").augends:register_group({
          default = {
            augend.constant.new({ elements = { "yes", "no" }, word = true, cyclic = true }),
            augend.constant.new({ elements = { "true", "false" }, word = true, cyclic = true }),
            augend.constant.new({ elements = { "True", "False" }, word = true, cyclic = true }),
            augend.constant.new({ elements = { "TRUE", "FALSE" }, word = true, cyclic = true }),
            augend.constant.new({ elements = { "[ ]", "[x]" }, word = false, cyclic = true }),
            augend.integer.new({ radix = 10, natural = false }),
            augend.integer.alias.hex,
            augend.integer.alias.binary,
            augend.date.alias["%Y/%m/%d"],
            augend.date.alias["%H:%M:%S"],
          },
        })
      end,
      keys = {
        { "<C-a>", "<Plug>(dial-increment)", mode = { "n", "x" }, desc = "increment next" },
        { "<C-x>", "<Plug>(dial-decrement)", mode = { "n", "x" }, desc = "decrement next" },
        { "g<C-a>", "<Plug>(dial-increment-additional)", mode = "x", desc = "increment additional" },
        { "g<C-x>", "<Plug>(dial-decrement-additional)", mode = "x", desc = "decrement additional" },
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
        lsp = {
          enabled = true,
          actions = true,
          completion = true,
          hover = true,
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
    },
    {
      "https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
      config = function()
        vim.g.rainbow_delimiters = {
          strategy = {
            [""] = function()
              local rb = require("rainbow-delimiters")
              return require("user.utils").is_disable_treesitter() and rb.strategy["noop"] or rb.strategy["global"]
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
    { "mfussenegger/nvim-dap", event = "VeryLazy", config = l("dap") },
    { "rcarriga/nvim-dap-ui" },
    { "theHamsta/nvim-dap-virtual-text" },
    { "mfussenegger/nvim-dap-python" },
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
      },
    },
    { "nmac427/guess-indent.nvim", opts = {} },
    { "nvimtools/hydra.nvim", lazy = true },
    -- { "obsidian-nvim/obsidian.nvim" },
    {
      "renerocksai/telekasten.nvim",
      config = function()
        require("telekasten").setup({
          home = vim.fn.expand("~/zettelkasten"),
          image_subdir = "img",
          dailies = "daily",
          weeklies = "weekly",
          image_link_style = "wiki",
          subdirs_in_links = true,
          clipboard_program = "xclip",
          auto_set_filetype = false,
        })
        vim
          .iter({
            { "<space>zz", "<cmd>Telekasten panel<CR>", "zettelkasten panel" },
            { "<space>zp", "<cmd>Telekasten find_notes<CR>", "zettelkasten find notes" },
            { "<space>z-", "<cmd>Telekasten find_friends<CR>", "zettelkasten find link" },
            { "<space>z_", "<cmd>Telekasten search_notes<CR>", "zettelkasten search notes" },
            { "<space>zr", "<cmd>Telekasten rename_note<CR>", "zettelkasten rename note" },
            { "<space>zd", "<cmd>Telekasten goto_today<CR>", "zettelkasten goto today" },
            { "<space>za", "<cmd>Telekasten new_note<CR>", "zettelkasten new note" },
            { "<space>zb", "<cmd>Telekasten show_backlinks<CR>", "zettelkasten show backlinks" },
            { "<space>zt", "<cmd>Telekasten show_tags<CR>", "zettelkasten show tags" },
            { "<space>zii", "<cmd>Telekasten insert_img_link<CR>", "zettelkasten insert image link" },
            { "<space>zip", "<cmd>Telekasten paste_img_and_link<CR>", "zettelkasten paste image" },
          })
          :each(function(mapping)
            local keymap, command, description = unpack(mapping)
            vim.keymap.set("n", keymap, command, { desc = description })
          end)
      end,
    },
    {
      "toppair/peek.nvim",
      ft = { "markdown" },
      build = "deno task --quiet build:fast",
      config = function()
        local peek = require("peek")
        peek.setup({
          app = "browser",
          filetype = { "markdown", "telekasten" },
        })
        vim.api.nvim_create_user_command("PeekOpen", peek.open, {})
        vim.api.nvim_create_user_command("PeekClose", peek.close, {})
        local function toggle_markdown()
          if peek.is_open() then
            peek.close()
          else
            peek.open()
          end
        end
        vim.keymap.set("n", "<space>tm", toggle_markdown, { desc = "toggle markdown preview" })
      end,
    },
    {
      "FabijanZulj/blame.nvim",
      opts = {},
      keys = { { "<space>tb", "<CMD>BlameToggle virtual<CR>", desc = "toggle blamer" } },
    },
    { "jbyuki/venn.nvim", config = l("venn"), keys = { "<space>v" } },
    { "lark-parser/vim-lark-syntax" },
  })
end

require("lazy").setup(plugins, {
  defaults = { lazy = false },
  checker = { enabled = false },
  ui = { border = config.border },
  performance = { cache = { enabled = true }, rtp = { disabled_plugins = disabled_plugins } },
})

vim.keymap.set("n", "<space>ol", "<ESC>:Lazy<CR>", { desc = "install, clean, and update plugins" })
