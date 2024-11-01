local F = require("user.functional")

local M = {}

M.minimal = os.getenv("MINIMAL_CONFIG")
M.log_load = vim.log.levels.OFF
M.rg_maximum_lines = 100
M.log_level = vim.log.levels.INFO
M.max_buffer_size = 300 * 1024
M.big_files_allowlist = { "help" }
M.border = "rounded"
M.icons = {
  Branch = "󰘬",
  Fix = "",
  Todo = "",
  Hack = "",
  Perf = "",
  Note = "󰍨",
  Test = "",
  Error = "",
  ErrorAlt = "󰅚",
  Warn = "",
  WarnAlt = "󰀪",
  Info = "",
  InfoAlt = "󰋽",
  Hint = "󰌵",
  HintAlt = "󰌶",
  File = "󰈙",
  Namespace = "",
  Package = "",
  Constructor = "",
  Enum = "󰕘",
  EnumMember = "",
  Constant = "󰏿",
  String = "󰀬",
  Number = "󰎠",
  Boolean = "󰔡",
  Array = "󰅪",
  Object = "󰅩",
  Key = "󰌋",
  Null = "󰟢",
  Version = "󰜢",
  Feature = "󰜢",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "󰊄",
  Text = "󰉿",
  Class = "󰄋",
  Method = "󱢖",
  Function = "󰊕",
  Field = "󰜢",
  Variable = "󰀫",
  Interface = "󱂛",
  Module = "",
  Property = "󰜢",
  Unit = "󰑭",
  Value = "󰎠",
  Keyword = "󰌋",
  Snippet = "󰗀",
  Color = "󰏘",
  Reference = "",
  Folder = "󰉋",
  Struct = "󰙅",
  KnownColor = "󰝤", -- ■  
  Yank = "󰏢",
  Path = "/",
  Tmux = "󰓫",
  Modified = "󰏫",
  Readonly = "",
}
M.rooter = {
  {
    ends_with = {
      "/nvim",
      "/node_modules",
    },
    contains = {
      ".bzr",
      ".git",
      ".hg",
      ".latexmkrc",
      ".luarc.json",
      ".svn",
      "Cargo.toml",
      "Makefile",
      "Pipfile",
      "Pipfile.lock",
      "_darcs",
      "node_modules",
      "package-lock.json",
      "package.json",
      "pyproject.toml",
      "requirements.txt",
    },
    patterns = { "/lib/python3.[0-9]*$" },
  },
  {
    1,
    ends_with = { "/site-packages" },
    patterns = { "/lib/python3.[0-9]*$" },
  },
}
M.lsp_ensure_installed = { "basedpyright", "ruff", "ts_ls", "jsonls", "bashls" }
M.mason_ensure_installed = { "prettierd" }
M.lsp_configs = {
  -- latex = {
  --   settings = {
  --     texlab = {
  --       build = {
  --         forwardSearchAfter = true,
  --         onSave = true,
  --       },
  --       forwardSearch = {
  --         executable = "zathura",
  --         args = { "--synctex-forward", "%l:1:%f", "%p" },
  --       },
  --     },
  --   },
  -- },
  rust_analyzer = {
    inlayHints = {
      closureCaptureHints = { enable = true },
      closureReturnTypeHints = { enable = "always" },
      discriminantHints = { enable = "always" },
      maxLength = 50,
      renderColons = false,
    },
    lspconfig_ignore = true,
    checkOnSave = { command = "clippy" },
    hover = {
      actions = {
        gotoTypeDef = { enable = false },
        implementations = { enable = false },
        references = { enable = false },
      },
    },
    completion = { postfix = { enable = false } },
  },
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
          showWord = "Disable",
        },
        hint = {
          enable = true,
        },
      },
    },
  },
  jsonls = {
    settings = {
      json = {
        schemas = {
          {
            fileMatch = { "*test.json" },
            url = os.getenv("HOME") .. "/experiments/schema-test.json",
          },
        },
        validate = { enable = true },
      },
    },
    lspconfig_hook = function(opts)
      F.load("schemastore", function(schemastore)
        opts = require("user.utils").tbl_merge(opts, {
          settings = {
            json = { schemas = schemastore.json.schemas() },
          },
        })
      end)
    end,
  },
  ltex = {
    filetypes = { "tex" },
    settings = {
      ltex = {
        checkFrequency = "save",
        language = "en-US",
      },
    },
  },
  yamlls = {
    settings = {
      yaml = {
        schemas = {
          [os.getenv("HOME") .. "/comparefile/schema/sw-config.schema.json"] = "*sw-config.yaml",
          [os.getenv("HOME") .. "/comparefile/schema/sw-plugin-config.schema.json"] = "sw-plugin-config.yaml",
        },
      },
    },
  },
  tailwindcss = {
    settings = {
      tailwindCSS = {
        colorDecorators = false,
      },
    },
  },
  r_language_server = {
    settings = {
      r = {
        lsp = {
          diagnostics = false,
          max_completions = 20,
        },
      },
    },
  },
}
M.linters = {
  text = {},
  tex = { "chktex", "lacheck", "vale" },
  cpp = { "cppcheck" },
  javascript = { "cspell" },
  markdown = { "cspell" },
  python = { "cspell" },
  lua = { "luacheck" },
}
M.formatters = {
  clients = {
    "jsonls",
    "rust-analyzer",
  },
  args = {
    ruff_fix = { "--unfixable", "F401,F811,F841" },
    latexindent = { "-y", 'defaultIndent:"  ",verbatimEnvironments:Verbatim:1;pre:1;textpre:1;rawpre:1' },
    shfmt = { "-i", "2", "-ci" },
    stylua = { "--config-path", vim.fn.expand("~/.config/stylua.toml") },
  },
  filetype = {
    python = { "ruff_fix", "ruff_format" },
    json = { "jq" },
    html = { "prettierd", "prettier" },
    javascript = { "prettierd", "prettier" },
    javascriptreact = { "prettierd", "prettier" },
    typescript = { "prettierd", "prettier" },
    typescriptreact = { "prettierd", "prettier" },
    markdown = { "prettierd", "prettier" },
    yaml = { "prettierd", "prettier" },
    cpp = { "clang_format" },
    c = { "clang_format" },
    toml = { "taplo" },
    r = { "styler" },
    tex = { "latexindent" },
    sh = { "shfmt" },
    lua = { "stylua" },
    xml = { "xmlformat" },
    pest = { "pestfmt" },
    xj = { "xj" },
    xjl = { "xjl" },
  },
}
M.treesitter = {
  ensure_installed = {
    "bash",
    "bibtex",
    "c",
    "comment",
    "cpp",
    "css",
    "dockerfile",
    "vimdoc",
    "html",
    "javascript",
    "json",
    "latex",
    "lua",
    "make",
    "markdown",
    "python",
    "rust",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "yaml",
  },
  highlight_disable = {},
}
M.closable_terminals = { "term://repl*", "term://toggleterm" }
M.custom_plugin_path = vim.fn.stdpath("config") .. "/custom_plugins"
M.repls = {
  python = { "ipython", "python", "python3", "qtconsole" },
  r = { "radian", "R" },
  lua = { "lua5.4", "luajit" },
}

return M
