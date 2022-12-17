local M = {}

M.minimal = os.getenv("MINIMAL_CONFIG")
M.lsp_signs = {
  Error = " ",
  Warning = " ",
  Hint = " ",
  Information = " ",
}
M.navic_icons = {
  File = " ",
  Module = " ",
  Namespace = " ",
  Package = " ",
  Class = " ",
  Method = " ",
  Property = " ",
  Field = " ",
  Constructor = " ",
  Enum = "練",
  Interface = "練",
  Function = " ",
  Variable = " ",
  Constant = " ",
  String = " ",
  Number = " ",
  Boolean = "◩ ",
  Array = " ",
  Object = " ",
  Key = " ",
  Null = "ﳠ ",
  EnumMember = " ",
  Struct = " ",
  Event = " ",
  Operator = " ",
  TypeParameter = " ",
}
M.rooter = {
  ends_with = {
    "/nvim",
    "/node_modules",
  },
  has = {
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
  parent_ends_with = {
    "/site-packages",
  },
  patterns = {
    { 1, "/lib/python3.[0-9]*$" },
    { 0, "/lib/python3.[0-9]*$" },
  },
}
M.whitespace_blacklist = {
  "",
  "TelescopePrompt",
  "TelescopeResults",
  "Trouble",
  "diff",
  "fugitive",
  "git",
  "gitcommit",
  "help",
  "markdown",
  "qf",
  "unite",
  "checkhealth",
}
M.illuminate_blacklist = {
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
M.lsp_ensure_installed = { "pyright", "tsserver", "jsonls", "bashls" }
M.mason_ensure_installed = { "black", "isort", "prettierd" }
M.lsp_configs = {
  -- latex = {
  -- 	settings = {
  -- 	  texlab = {
  -- 	    build = {
  -- 	      forwardSearchAfter = true;
  -- 	      onSave = true;
  -- 	    },
  -- 	    forwardSearch = {
  -- 	      executable = "zathura",
  -- 	      args = { "--synctex-forward", "%l:1:%f", "%p" }
  -- 	    }
  -- 	  }
  -- 	}
  -- },

  jsonls = {
    settings = {
      json = {
        schemas = {
          {
            fileMatch = { "*test.json" },
            url = os.getenv("HOME") .. "/experiments/schema-test.json",
          },
        },
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
          useLibraryCodeForTypes = false,
          typeCheckingMode = "off",
        },
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
M.null_ls = {
  code_actions = {},
  diagnostics = {
    -- "chktex",
    -- "eslint_d",
    -- "pylint"
  },
  formatting = {
    -- "beautysh",
    "black",
    "clang_format",
    "eslint_d",
    "isort",
    "prettierd",
    "taplo",
    latexindent = {
      extra_args = { "-y", [[defaultIndent: "  "]] },
    },
    shfmt = {
      extra_args = { "-i", "2", "-ci" },
    },
    "styler",
    stylua = {
      extra_args = { "--config-path", vim.fn.expand("~/.config/stylua.toml") },
    },
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
M.format_clients = {
  "null-ls",
  "rust_analyzer",
}
M.linters = {
  text = { "languagetool" },
  tex = { "chktex" },
  cpp = { "cppcheck" },
  javascript = { "eslint" },
  markdown = { "markdownlint" },
  python = { "pylint" },
  lua = { "luacheck" },
}
M.repls = {
  python = { command = { "ipython" } },
  r = { command = { "radian" } },
}
M.brackets = {
  { "(", ")" },
  { "[", "]" },
  { "{", "}" },
  { "<", ">" },
}
M.quotes = { '"', "'", "`" }
M.closable_terminals = { "term://repl*", "term://toggleterm" }
M.colorizer_disable_filetypes = {
  "r",
  "",
}

return M
