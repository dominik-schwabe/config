local def_opt = { noremap = true, silent = true }
local noremap = { noremap = true }

local treesitter_config = require("myconfig.config").treesitter
local rainbow = require("myconfig.color").rainbow

require("nvim-treesitter.configs").setup({
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
  additional_vim_regex_highlighting = false,
})

vim.keymap.set("n", "<space>tt", "<CMD>TSModuleInfo<CR>", noremap)
vim.keymap.set("n", "<space>tc", "<CMD>TSConfigInfo<CR>", noremap)
vim.keymap.set("n", "<space>ti", ":TSInstall ", noremap)
vim.keymap.set("n", "<space>tu", "<CMD>TSUpdate<CR>", noremap)

local tsht = require("tsht")
tsht.config.hint_keys = { "j", "f", "h", "g", "d", "k", "s", "l", "a" }

vim.keymap.set("o", "m", ":<C-U>lua require('tsht').nodes()<CR>", def_opt)
vim.keymap.set("x", "m", ":lua require('tsht').nodes()<CR>", def_opt)
