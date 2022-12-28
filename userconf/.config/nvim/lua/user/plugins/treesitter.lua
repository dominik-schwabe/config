local config = require("user.config")
local treesitter_config = config.treesitter
local rainbow = require("user.color").rainbow

local F = require("user.functional")

local ensure_installed = config.minimal and {} or treesitter_config.ensure_installed

F.load("nvim-treesitter.configs", function(tc)
  tc.setup({
    playground = {
      enable = false,
      disable = {},
      updatetime = 25,
      persist_queries = false,
      keybindings = {
        toggle_query_editor = "o",
        toggle_hl_groups = "i",
        toggle_injected_languages = "t",
        toggle_anonymous_nodes = "a",
        toggle_language_display = "I",
        focus_language = "f",
        unfocus_language = "F",
        update = "R",
        goto_node = "<cr>",
        show_help = "?",
      },
    },
    highlight = {
      enable = true,
      disable = treesitter_config.highlight_disable,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = ")",
        node_incremental = ")",
        node_decremental = "(",
      },
    },
    markid = {
      enable = false,
      colors = {
        "#ffffff",
        "#eeeeee",
        "#dddddd",
        "#cccccc",
        "#bbbbbb",
        "#aaaaaa",
        "#999999",
        "#888888",
        "#777777",
        "#666666",
        "#555555",
      },
    },
    matchup = {
      enable = false,
    },
    indent = {
      enable = false,
    },
    rainbow = {
      colors = rainbow,
      enable = true,
      extended_mode = true,
      max_file_lines = 1000,
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          -- ["}"] = "@function.outer",
          ['"'] = "@class.outer",
        },
        -- goto_next_end = {
        --   ["]M"] = "@function.outer",
        --   ["]["] = "@class.outer",
        -- },
        goto_previous_start = {
          -- ["{"] = "@function.outer",
          ["!"] = "@class.outer",
        },
        -- goto_previous_end = {
        --   ["[M"] = "@function.outer",
        --   ["[]"] = "@class.outer",
        -- },
      },
      swap = {
        enable = true,
        swap_next = {
          ["U"] = "@parameter.inner",
        },
        swap_previous = {
          ["R"] = "@parameter.inner",
        },
      },
    },
    autotag = {
      enable = true,
    },
    ensure_installed = ensure_installed,
    ignore_install = treesitter_config.ignore_install,
    context_commentstring = {
      enable = true,
      enable_autocmd = false,
    },
    additional_vim_regex_highlighting = false,
  })
end)

F.load("treesitter-unit", function(treesitter_unit)
  vim.keymap.set({ "x", "o" }, "iu", function()
    treesitter_unit.select(true)
  end, { desc = "inside unit" })
  vim.keymap.set({ "x", "o" }, "au", function()
    treesitter_unit.select()
  end, { desc = "all unit" })
end)
