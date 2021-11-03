local map = vim.api.nvim_set_keymap

local def_opt = {noremap = true, silent = true}
local noremap = {noremap = true}

local treesitter_config = require("config").treesitter
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = treesitter_config.highlight_disable
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = ")",
      node_incremental = ")",
      node_decremental = "(",
    }
  },
  matchup = {
    enable = true,
  },
  indent = {
    enable = false,
  },
  rainbow = {
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
  }
}

map("n", "<space>tt", "<CMD>TSModuleInfo<CR>", noremap)
map("n", "<space>tc", "<CMD>TSConfigInfo<CR>", noremap)
map("n", "<space>ti", ":TSInstall ", noremap)
map("n", "<space>tu", "<CMD>TSUpdate<CR>", noremap)

map("o", "m", ":<C-U>lua require('tsht').nodes()<CR>", def_opt)
map("x", "m", ":lua require('tsht').nodes()<CR>", def_opt)
require("tsht").config.hint_keys = { "j", "f", "h", "g", "d", "k", "s", "l", "a", "ö" }
