local map = vim.api.nvim_set_keymap
local def_opt = {noremap = true, silent = true}

require("telescope").setup({
  defaults = {
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ["<C-p>"] = require('telescope.actions').close,
      },
    },
    layout_config = { horizontal = { prompt_position = "top" } }
  }
})

map('', '<C-p>', '<cmd>Telescope find_files<cr>', def_opt)
map('i', '<C-p>', '<cmd>Telescope find_files<cr>', def_opt)
