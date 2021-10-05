local map = vim.api.nvim_set_keymap
local def_opt = {noremap = true, silent = true}

require("telescope").setup({
  defaults = {
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ["<C-p>"] = require('telescope.actions').close,
        ["<F5>"] = require('telescope.actions').close,
      },
      n = {
        ["<C-p>"] = require('telescope.actions').close,
        ["<F5>"] = require('telescope.actions').close,
      },
    },
    layout_config = { horizontal = { prompt_position = "top" } }
  }
})

map('', '<C-p>', '<CMD>Telescope find_files<CR>', def_opt)
map('i', '<C-p>', '<CMD>Telescope find_files<CR>', def_opt)
map('', "<F5>", "<CMD>Telescope live_grep<CR>", def_opt)
map('i', "<F5>", "<CMD>Telescope live_grep<CR>", def_opt)
map('', 'z=', '<CMD>Telescope spell_suggest<CR><ESC>', def_opt)
map('', '<space>jc', '<CMD>Telescope highlights<CR>', def_opt)
map('', '<space>jk', '<CMD>Telescope keymaps<CR>', def_opt)
map('', '<space>jgb', '<CMD>Telescope git_branches<CR>', def_opt)
map('', '<space>jgs', '<CMD>Telescope git_status<CR>', def_opt)
map('', '<space>jh', '<CMD>Telescope help_tags<CR>', def_opt)
map('', '<space>jj', '<CMD>Telescope jump_list<CR>', def_opt)
map('', '<space>js', '<CMD>Telescope document_symbols<CR>', def_opt)
map('', '<space>jb', '<CMD>Telescope current_buffer_fuzzy_find<CR>', def_opt)
