local M = {}

M.minimal = os.getenv("MINIMAL_CONFIG")
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
  Tailwind = "󰝤", -- ■  
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
M.lsp_ensure_installed = { "pyright", "tsserver", "jsonls", "bashls" }
M.mason_ensure_installed = { "black", "isort", "prettierd" }
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
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          showWord = "Disable",
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
        validate = {
          enable = true,
        },
      },
    },
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
  pyright = {
    settings = {
      pyright = {
        disableOrganizeImports = true,
      },
      python = {
        analysis = {
          diagnosticMode = "openFilesOnly",
          useLibraryCodeForTypes = true,
          typeCheckingMode = "off",
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
  text = { "languagetool" },
  tex = { "chktex", "lacheck", "vale" },
  cpp = { "cppcheck" },
  javascript = { "eslint" },
  markdown = { "markdownlint" },
  python = { "pylint" },
  lua = { "luacheck" },
}
M.formatters = {
  clients = {
    "jsonls",
    "rust_analyzer",
  },
  args = {
    latexindent = { "-y", 'defaultIndent:"  ",verbatimEnvironments:Verbatim:1;pre:1;textpre:1;rawpre:1' },
    shfmt = { "-i", "2", "-ci" },
    stylua = { "--config-path", vim.fn.expand("~/.config/stylua.toml") },
  },
  filetype = {
    python = { "black", "isort" },
    json = { "jq" },
    html = { { "prettierd", "prettier" } },
    javascript = { { "prettierd", "prettier" } },
    javascriptreact = { { "prettierd", "prettier" } },
    typescript = { { "prettierd", "prettier" } },
    typescriptreact = { { "prettierd", "prettier" } },
    markdown = { { "prettierd", "prettier" } },
    yaml = { { "prettierd", "prettier" } },
    cpp = { "clang_format" },
    toml = { "taplo" },
    r = { "styler" },
    tex = { "latexindent" },
    sh = { "shfmt" },
    lua = { "stylua" },
    xml = { "xmlformat" },
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
    "http",
    "java",
    "javascript",
    "json",
    "latex",
    "lua",
    "make",
    "markdown",
    "python",
    "r",
    "rust",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "yaml",
  },
  highlight_disable = {},
}
M.quotes = { '"', "'", "`" }
M.closable_terminals = { "term://repl*", "term://toggleterm" }

return M
