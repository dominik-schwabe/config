local M = {}

M.lsp_signs = {
  Error = " ",
  Warning = " ",
  Hint = " ",
  Information = " ",
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
  "=site-packages",
  "=node_modules",
  "node_modules",
  "package.json",
  "package-lock.json",
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
}
M.whitespace_blacklist = {
  "TelescopePrompt",
  "Trouble",
  "diff",
  "fugitive",
  "git",
  "gitcommit",
  "help",
  "markdown",
  "qf",
  "unite",
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
  "term",
  "vista",
  "yaml",
}
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
          useLibraryCodeForTypes = true,
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
    "black",
    "clang_format",
    "eslint_d",
    "isort",
    "prettierd",
    shfmt = {
      extra_args = { "-i", "2", "-ci" },
    },
    "styler",
    stylua = {
      extra_args = { "--config-path", vim.fn.expand("~/.config/stylua.toml") },
    },
  },
}
local treesitter_min = {
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
}
M.treesitter = {
  ensure_installed = treesitter_min,
  highlight_disable = {},
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
