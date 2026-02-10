local F = require("user.functional")

local config = require("user.config")

local function desc(opts, description)
  return F.extend(opts, { desc = description })
end

local noop = function() end

local function bind_select_action(entries, opts)
  opts = opts or {}
  local buffer = opts.buffer
  local on_select = opts.on_select
  local format_item = opts.format_item
  local map_opts = { noremap = true, silent = true, buffer = buffer }
  vim.keymap.set({ "n", "x" }, "<leader>ch", function()
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

local function pick(name, opts)
  return function()
    require("snacks").picker.pick(name, opts)
  end
end

local plugins = F.concat({
  { "folke/lazy.nvim" },
  { "neovim/nvim-lspconfig", config = l("lspconfig") },
  { "mason-org/mason.nvim", opts = { ui = { border = config.border } } },
  { "mason-org/mason-lspconfig.nvim" },
  {
    "nvim-mini/mini.nvim",
    config = function()
      require("mini.comment").setup({
        options = {
          custom_commentstring = function(pos)
            return require("ts_context_commentstring").calculate_commentstring({ location = pos })
              or vim.bo.commentstring
          end,
          ignore_blank_line = true,
        },
      })
      require("mini.icons").setup()
      require("mini.icons").mock_nvim_web_devicons()
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    config = l("tree"),
    lazy = false,
    dependencies = { "nvim-mini/mini.nvim" },
    keys = {
      { "<F1>", "<ESC>:NvimTreeToggle<CR>", mode = { "n", "x", "i" } },
      { "<F1>", "<CMD>NvimTreeToggle<CR>", mode = { "t" } },
    },
  },
  -- { "nvim-tree/nvim-web-devicons" },
  { "saghen/blink.cmp", version = "1.*", config = l("blink") },
  { "mgalliou/blink-cmp-tmux" },
  { "rafamadriz/friendly-snippets" },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    opts = {
      languages = {
        sparql = "# %s",
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      words = { debounce = 100 },
      notifier = {},
      picker = {
        limit_live = 500,
        previewers = {
          file = { max_size = 256 * 1024 },
        },
        win = {
          input = {
            keys = {
              ["<F1>"] = { noop, mode = { "n", "i" } },
              ["<F3>"] = { noop, mode = { "n", "i" } },
              ["<F24>"] = { "toggle_maximize", mode = { "i", "n" } },
              ["<Esc>"] = { "close", mode = { "n", "i" } },
              ["<c-c>"] = { "stopinsert" },
              ["<c-o>"] = { "focus_input", mode = { "n", "i" } },
              ["<c-p>"] = { "focus_preview", mode = { "n", "i" } },
              ["<c-l>"] = { "focus_list", mode = { "n", "i" } },
              ["<F7>"] = { "toggle_preview", mode = { "i", "n" } },
              ["<F8>"] = { "toggle_follow", mode = { "i", "n" } },
              ["<F9>"] = { "toggle_ignored", mode = { "i", "n" } },
              ["<F10>"] = { "toggle_hidden", mode = { "i", "n" } },
              ["<F11>"] = { "toggle_live", mode = { "i", "n" } },
              ["<F12>"] = { "toggle_regex", mode = { "i", "n" } },
            },
          },
          list = {
            keys = {
              ["<c-o>"] = "focus_input",
              ["<c-p>"] = "focus_preview",
              ["<c-l>"] = "focus_list",
              ["<Esc>"] = "close",
            },
          },
          preview = {
            keys = {
              ["<Esc>"] = "close",
              ["<c-o>"] = "focus_input",
              ["<c-p>"] = "focus_preview",
              ["<c-l>"] = "focus_list",
              ["<c-j>"] = "list_down",
              ["<c-k>"] = "list_up",
              ["<CR>"] = "confirm",
            },
          },
        },
      },
      input = {
        icon = "",
        win = {
          relative = "cursor",
          row = -3,
          col = -1,
          width = 28,
        },
      },
    },
    keys = {
      {
        "<leader>,,",
        function()
          require("snacks").picker.resume()
        end,
        desc = "Resume",
      },
      { "<C-p>", pick("files"), desc = "Find Files" },
      { "z=", pick("spelling"), desc = "Spell Suggest" },
      { "_", pick("grep"), desc = "Grep" },
      { "<leader>-", pick("grep_word"), desc = "Visual selection or word", mode = { "n", "x" } },
      { "<leader>/", pick("lines"), desc = "Buffer Lines" },
      -- find
      { "<leader>,fb", pick("buffers"), desc = "Buffers" },
      { "<leader>,fc", pick("files", { cwd = vim.fn.stdpath("config") }), desc = "Find Config File" },
      { "<leader>,fg", pick("git_files"), desc = "Find Git Files" },
      { "<leader>,fp", pick("projects"), desc = "Projects" },
      { "<leader>,fr", pick("recent"), desc = "Recent" },
      -- git
      { "<leader>,gb", pick("git_branches"), desc = "Git Branches" },
      { "<leader>,gl", pick("git_log"), desc = "Git Log" },
      { "<leader>,gL", pick("git_log_line"), desc = "Git Log Line" },
      { "<leader>,gs", pick("git_status"), desc = "Git Status" },
      { "<leader>,gS", pick("git_stash"), desc = "Git Stash" },
      { "<leader>,gD", pick("git_diff"), desc = "Git Diff (Hunks)" },
      { "<leader>,gf", pick("git_log_file"), desc = "Git Log File" },
      -- gh
      { "<leader>,gi", pick("gh_issue"), desc = "GitHub Issues (open)" },
      { "<leader>,gI", pick("gh_issue", { state = "all" }), desc = "GitHub Issues (all)" },
      { "<leader>,gp", pick("gh_pr"), desc = "GitHub Pull Requests (open)" },
      { "<leader>,gP", pick("gh_pr", { state = "all" }), desc = "GitHub Pull Requests (all)" },
      -- search
      { '<leader>,"', pick("registers"), desc = "Registers" },
      { "<leader>,/", pick("search_history"), desc = "Search History" },
      { "<leader>,a", pick("autocmds"), desc = "Autocmds" },
      { "<leader>,c", pick("command_history"), desc = "Command History" },
      { "<leader>,C", pick("commands"), desc = "Commands" },
      { "<leader>oD", pick("diagnostics_buffer"), desc = "Buffer Diagnostics" },
      { "<leader>oW", pick("diagnostics"), desc = "Diagnostics" },
      { "<leader>,i", pick("icons"), desc = "Icons" },
      { "<leader>,j", pick("jumps"), desc = "Jumps" },
      { "<leader>,q", pick("qflist"), desc = "Quickfix List" },
      { "<leader>,l", pick("loclist"), desc = "Location List" },
      { "<leader>,m", pick("marks"), desc = "Marks" },
      { "<leader>,M", pick("man"), desc = "Man Pages" },
      { "<leader>,h", pick("help"), desc = "Help Pages" },
      { "<leader>,H", pick("highlights"), desc = "Highlights" },
      { "<leader>,k", pick("keymaps"), desc = "Keymaps" },
      { "<leader>,:", pick("command_history"), desc = "Command History" },
      { "<leader>,n", pick("notifications"), desc = "Notification History" },
    },
  },
  { "kylechui/nvim-surround", config = true },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = config.formatters.filetype,
      formatters = config.formatters.formatters,
    },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({
            async = true,
            lsp_fallback = true,
            filter = function(client)
              return vim.tbl_contains(config.formatters.clients, client.name)
            end,
          })
        end,
        mode = { "n", "x" },
        silent = true,
        desc = "format buffer",
      },
      {
        "<leader>.",
        function()
          require("conform").format({
            formatters = { "trim_whitespace", "trim_newlines" },
            async = true,
          })
        end,
        mode = { "n", "x" },
        desc = "trim whitespace and last empty lines",
      },
    },
  },
  {
    "kevinhwang91/nvim-bqf",
    opts = {
      auto_resize_height = false,
      func_map = {
        openc = "<CR>",
        vsplit = "<C-s>",
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
  {
    "stevearc/quicker.nvim",
    ft = "qf",
    opts = {
      highlight = {
        treesitter = false,
        lsp = false,
      },
    },
  },
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
      set({ "n", "v" }, "<leader>n", match_skip_cursor(-1))
      set({ "n", "v" }, "<leader>N", match_skip_cursor(1))

      set({ "n", "v" }, "<leader>ma", mc.matchAllAddCursors)

      set({ "n", "v" }, "<leader>j", mc.nextCursor)
      set({ "n", "v" }, "<leader>k", mc.prevCursor)

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

      set("n", "<leader>mm", mc.restoreCursors)

      set("n", "<leader>ma", mc.alignCursors)

      set("v", "<leader>mr", mc.splitCursors)

      set("v", "I", mc.insertVisual)
      set("v", "A", mc.appendVisual)

      set("v", "M", mc.matchCursors)

      set("v", "<leader>mt", transpose_cursor(1))
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
      vim.keymap.set("n", "<leader>,r", function()
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
        after_open = function(repl)
          F.load("colorizer", function(colorizer)
            colorizer.attach_to_buffer(repl.bufnr)
          end)
        end,
        on_stdout = function(repl)
          F.load("colorizer", function(colorizer)
            if colorizer.is_buffer_attached(repl.bufnr) then
              local debounce_timer = repl.colorizer_debounce
              if debounce_timer == nil then
                debounce_timer = vim.loop.new_timer()
                repl.colorizer_debounce = debounce_timer
              end
              debounce_timer:stop()
              debounce_timer:start(
                50,
                0,
                vim.schedule_wrap(function()
                  colorizer.rehighlight(repl.bufnr, require("colorizer.config").options.user_default_options)
                end)
              )
            end
          end)
        end,
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
            vim.keymap.set("n", "<leader><leader>", F.f(send.buffer)(), desc(map_opt, "send buffer"))
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
    { "pmizio/typescript-tools.nvim", opts = {}, dependencies = { "nvim-lua/plenary.nvim" } },
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
          body = "<leader>cc",
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
      keys = { "<leader>cc" },
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
        {
          "<C-a>",
          function()
            require("dial.map").manipulate("increment", "normal")
          end,
          mode = "n",
          desc = "increment normal",
        },
        {
          "<C-x>",
          function()
            require("dial.map").manipulate("decrement", "normal")
          end,
          mode = "n",
          desc = "decrement normal",
        },
        {
          "g<C-a>",
          function()
            require("dial.map").manipulate("increment", "gnormal")
          end,
          mode = "n",
          desc = "increment gnormal",
        },
        {
          "g<C-x>",
          function()
            require("dial.map").manipulate("decrement", "gnormal")
          end,
          mode = "n",
          desc = "decrement gnormal",
        },
        {
          "<C-a>",
          function()
            require("dial.map").manipulate("increment", "visual")
          end,
          mode = "x",
          desc = "increment visual",
        },
        {
          "<C-x>",
          function()
            require("dial.map").manipulate("decrement", "visual")
          end,
          mode = "x",
          desc = "decrement visual",
        },
        {
          "g<C-a>",
          function()
            require("dial.map").manipulate("increment", "gvisual")
          end,
          mode = "x",
          desc = "increment gvisual",
        },
        {
          "g<C-x>",
          function()
            require("dial.map").manipulate("decrement", "gvisual")
          end,
          mode = "x",
          desc = "decrement gvisual",
        },
      },
    },
    {
      "altermo/ultimate-autopair.nvim",
      event = { "InsertEnter", "CmdlineEnter" },
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
          { "`", "`", nft = { "python", "jon", "cjon" } },
        },
      },
    },
    {
      "catgoose/nvim-colorizer.lua",
      opts = {
        user_default_options = {
          names = false,
          rgb_fn = true,
          hsl_fn = true,
          tailwind = true,
        },
      },
      lazy = false,
      keys = {
        { "<leader>tc", "<CMD>ColorizerToggle<CR>", desc = "toggle colorizer" },
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
      keys = { { "<leader>ot", "<CMD>TodoQuickFix<CR>", desc = "show todos in quickfix" } },
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
    {
      "obsidian-nvim/obsidian.nvim",
      opts = {
        legacy_commands = false,
        ui = { enable = false },
        workspaces = {
          {
            name = "personal",
            path = "~/zettelkasten",
          },
        },
      },
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
        vim.keymap.set("n", "<leader>tm", toggle_markdown, { desc = "toggle markdown preview" })
      end,
    },
    {
      "FabijanZulj/blame.nvim",
      opts = {},
      keys = { { "<leader>tb", "<CMD>BlameToggle virtual<CR>", desc = "toggle blamer" } },
    },
    { "jbyuki/venn.nvim", config = l("venn"), keys = { "<leader>v" } },
  })
end

require("lazy").setup(plugins, {
  defaults = { lazy = false },
  checker = { enabled = false },
  ui = { border = config.border },
  performance = { cache = { enabled = true }, rtp = { disabled_plugins = disabled_plugins } },
})

vim.keymap.set("n", "<leader>ol", "<ESC>:Lazy<CR>", { desc = "install, clean, and update plugins" })
