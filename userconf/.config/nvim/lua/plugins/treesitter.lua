-- TODO: textobjects
local map = vim.api.nvim_set_keymap

local def_opt = {noremap = true, silent = true}
local noremap = {noremap = true}

require('telescope').load_extension('projects')
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
  },
  matchup = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = 1000,
  },
  textobjects = {
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
  textsubjects = {
      enable = true,
      keymaps = {
          ['.'] = 'textsubjects-smart',
          [';'] = 'textsubjects-container-outer',
      }
  },
  ensure_installed = "all",
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
map("v", "m", ":lua require('tsht').nodes()", def_opt)
require("tsht").config.hint_keys = { "j", "f", "h", "g",  "d", "k", "s", "l", "a", "ö" }
