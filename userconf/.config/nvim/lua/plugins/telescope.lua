local cmd = vim.cmd
local map = vim.api.nvim_set_keymap
local def_opt = {noremap = true, silent = true}

local function stopinsert()
  cmd("stopinsert")
end
require("telescope").setup({
  defaults = {
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ["<C-p>"] = require('telescope.actions').close,
        ["<F11>"] = require('telescope.actions').close,
        ["<C-c>"] = stopinsert,
        ["<ESC>"] = require('telescope.actions').close
      },
      n = {
        ["<C-p>"] = require('telescope.actions').close,
        ["<F11>"] = require('telescope.actions').close,
      },
    },
    layout_config = { horizontal = { prompt_position = "top" } }
  }
})

map('', '<C-p>', '<CMD>Telescope find_files<CR>', def_opt)
map('i', '<C-p>', '<CMD>Telescope find_files<CR>', def_opt)
map('', "<F11>", "<CMD>Telescope live_grep<CR>", def_opt)
map('i', "<F11>", "<CMD>Telescope live_grep<CR>", def_opt)
map('n', 'z=', '<CMD>Telescope spell_suggest<CR><ESC>', def_opt)
map('', '<space>jc', '<CMD>Telescope highlights<CR>', def_opt)
map('', '<space>jk', '<CMD>Telescope keymaps<CR>', def_opt)
map('', '<space>jgb', '<CMD>Telescope git_branches<CR>', def_opt)
map('', '<space>jgs', '<CMD>Telescope git_status<CR>', def_opt)
map('', '<space>jh', '<CMD>Telescope help_tags<CR>', def_opt)
map('', '<space>jj', '<CMD>Telescope jump_list<CR>', def_opt)
map('', '<space>js', '<CMD>Telescope document_symbols<CR>', def_opt)
map('', '<space>jb', '<CMD>Telescope current_buffer_fuzzy_find<CR>', def_opt)
