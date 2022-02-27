local map = vim.api.nvim_set_keymap

local def_opt = { noremap = true, silent = true }
local noremap = { noremap = true }

local treesitter_config = require("myconfig.config").treesitter
require("nvim-treesitter.configs").setup({
  playground = {
    enable = false,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
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
  matchup = {
    enable = false,
  },
  indent = {
    enable = false,
  },
  rainbow = {
    colors = {
      '#bb00bb',
      '#00bb00',
      '#00bbbb',
      '#bb0000',
      '#bbbb00',
    },
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
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
    -- swap = {
    --   enable = true,
    --   swap_next = {
    --     ["U"] = "@parameter.inner",
    --   },
    --   swap_previous = {
    --     ["R"] = "@parameter.inner",
    --   },
    -- },
  },
  autotag = {
    enable = true,
  },
  ensure_installed = treesitter_config.ensure_installed,
  ignore_install = treesitter_config.ignore_install,
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
})

map("n", "<space>tt", "<CMD>TSModuleInfo<CR>", noremap)
map("n", "<space>tc", "<CMD>TSConfigInfo<CR>", noremap)
map("n", "<space>ti", ":TSInstall ", noremap)
map("n", "<space>tu", "<CMD>TSUpdate<CR>", noremap)

map("o", "m", ":<C-U>lua require('tsht').nodes()<CR>", def_opt)
map("x", "m", ":lua require('tsht').nodes()<CR>", def_opt)
require("tsht").config.hint_keys = { "j", "f", "h", "g", "d", "k", "s", "l", "a", "ö" }
