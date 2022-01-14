local M = {}

M.lsp_signs = {
  Error = " ",
  Warning = " ",
  Hint = " ",
  Information = " ",
}
M.whitespace_blacklist = {
  "diff",
  "git",
  "gitcommit",
  "unite",
  "qf",
  "help",
  "markdown",
  "fugitive",
  "TelescopePrompt",
  "Trouble",
}
M.lspkind_symbol_map = {
  Text = "",
  Method = "",
  Function = "",
  Constructor = "",
  Field = "ﰠ",
  Variable = "",
  Class = "ﴯ",
  Interface = "",
  Module = "",
  Property = "ﰠ",
  Unit = "塞",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "פּ",
  Event = "",
  Operator = "",
  TypeParameter = "",
}
M.gps_icons = {
  ["class-name"] = " ",
  ["function-name"] = " ",
  ["method-name"] = " ",
  ["container-name"] = " ",
  ["tag-name"] = "炙",
}
M.root_patterns = {
  "=nvim",
  ".git",
  "_darcs",
  ".hg",
  ".bzr",
  ".svn",
  ".latexmkrc",
  "Makefile",
  "package.json",
  "Pipfile",
  "Pipfile.lock",
  "requirements.txt",
  -- "requirements.txt",
  -- "Pipfile",
  -- "Pipfile.lock",
}
M.illuminate_blacklist = {
  "Trouble",
  "NvimTree",
  "qf",
  "vista",
  "packer",
  "help",
  "term",
  "fugitiveblame",
  "lsputil_codeaction_list",
  "",
  "markdown",
  "yaml",
  "json",
}
M.colorscheme = "monokai"
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

  -- jsonls = {
  --   settings = {
  --     json = {
  --       schemas = require("schemastore").json.schemas(),
  --     },
  --   },
  -- },

  pyright = {
    settings = {
      pyright = {
        disableOrganizeImports = true,
      },
      python = {
        analysis = {
          diagnosticMode = "openFilesOnly",
          useLibraryCodeForTypes = false,
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
    "black",
    "clang_format",
    "eslint_d",
    "isort",
    "prettierd",
    shfmt = {
      extra_args = { "-i", "2", "-ci" },
    },
    "styler",
    "stylua",
  },
}
local treesitter_min = {
  "bash",
  "c",
  "comment",
  "cpp",
  "css",
  "dockerfile",
  "html",
  "java",
  "javascript",
  "json",
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
}
local ensure_installed = os.getenv("NVIM_TREESITTER_MAINTAINED") == "true" and "maintained" or treesitter_min
M.treesitter = {
  ensure_installed = ensure_installed,
  ignore_install = { "latex" },
  highlight_disable = { "r" },
}
M.coc_extensions = {
  "coc-clangd",
  "coc-css",
  "coc-docker",
  "coc-html",
  "coc-java",
  "coc-json",
  "coc-prettier",
  "coc-pyright",
  "coc-r-lsp",
  "coc-sh",
  "coc-snippets",
  "coc-tsserver",
  "coc-vimlsp",
  "coc-vimtex",
  "coc-yaml",
  "coc-sumneko-lua",
  "coc-texlab",
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
  python = "ipython",
  r = "radian",
}
M.colorizer_disable_filetypes = {
  "r",
  "term",
}

return M
