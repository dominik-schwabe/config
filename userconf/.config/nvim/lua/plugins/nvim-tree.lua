local def_opt = {noremap = true, silent = true}
local g = vim.g
local map = vim.api.nvim_set_keymap

local cb = require('nvim-tree.config').nvim_tree_callback
local mappings = {
  { key = {"<CR>", "o", "<2-LeftMouse>"}, cb = cb("edit") },
  { key = {"<2-RightMouse>", "<C-]>"},    cb = cb("cd") },
  { key = "<C-v>", cb = cb("vsplit") },
  { key = "<C-x>", cb = cb("split") },
  { key = "<C-t>", cb = cb("tabnew") },
  { key = "<",     cb = cb("prev_sibling") },
  { key = ">",     cb = cb("next_sibling") },
  { key = "P",     cb = cb("parent_node") },
  { key = "<BS>",  cb = cb("close_node") },
  { key = "<S-CR>",cb = cb("close_node") },
  { key = "<Tab>", cb = cb("preview") },
  { key = "K",     cb = cb("first_sibling") },
  { key = "J",     cb = cb("last_sibling") },
  { key = "I",     cb = cb("toggle_ignored") },
  { key = "H",     cb = cb("toggle_dotfiles") },
  { key = "R",     cb = cb("full_rename") },
  { key = "a",     cb = cb("create") },
  { key = "d",     cb = cb("remove") },
  { key = "r",     cb = cb("rename") },
  { key = "<C-r>", cb = cb("refresh") },
  { key = "x",     cb = cb("cut") },
  { key = "c",     cb = cb("copy") },
  { key = "p",     cb = cb("paste") },
  { key = "y",     cb = cb("copy_name") },
  { key = "Y",     cb = cb("copy_path") },
  { key = "gy",    cb = cb("copy_absolute_path") },
  { key = "[c",    cb = cb("prev_git_item") },
  { key = "]c",    cb = cb("next_git_item") },
  { key = "s",     cb = cb("system_open") },
  { key = "q",     cb = cb("close") },
  { key = "g?",    cb = cb("toggle_help") },
  { key = ".",     cb = cb("toggle_dotfiles")},
  { key = "i",     cb = cb("cd")},
  { key = "u",     cb = cb("dir_up")},
  { key = "s",     cb = cb("vsplit")},
}
g.nvim_tree_quit_on_open = 1
g.nvim_tree_hide_dotfiles = 1
g.nvim_tree_git_hl = 1
g.nvim_tree_highlight_opened_files = 2
g.nvim_tree_disable_window_picker = 1
g.nvim_tree_refresh_wait = 100
g.nvim_tree_respect_buf_cwd = 1

require('nvim-tree').setup {
  auto_close          = false,
  hijack_cursor       = false,
  update_cwd          = true,
  disable_netrw       = false,
  hijack_netrw        = true,
  update_focused_file = {
    enable      = true,
    update_cwd  = true,
  },
  view = {
    width = 32,
    mappings = {
      custom_only = true,
      list = mappings
    }
  }
}

map('', '<F1>', '<ESC>:NvimTreeToggle<CR>', def_opt)
map('i', '<F1>', '<ESC>:NvimTreeToggle<CR>', def_opt)
map('t', '<F1>', '<CMD>NvimTreeToggle<CR>', def_opt)
map('', 'gt', '<ESC>:NvimTreeFindFile<CR>', def_opt)
