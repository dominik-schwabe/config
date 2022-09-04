local nvim_tree = require("nvim-tree")
local utils = require("user.utils")

local mappings = {
  { key = { "<CR>", "o", "<2-LeftMouse>" }, action = "edit" },
  { key = "<C-e>", action = "edit_in_place" },
  { key = "O", action = "edit_no_picker" },
  { key = { "<C-]>", "<2-RightMouse>" }, action = "cd" },
  { key = "<C-v>", action = "vsplit" },
  { key = "<C-x>", action = "split" },
  { key = "<C-t>", action = "tabnew" },
  { key = "<", action = "prev_sibling" },
  { key = ">", action = "next_sibling" },
  { key = "P", action = "parent_node" },
  { key = "<BS>", action = "close_node" },
  { key = "<Tab>", action = "preview" },
  { key = "K", action = "first_sibling" },
  { key = "J", action = "last_sibling" },
  { key = "I", action = "toggle_git_ignored" },
  { key = "H", action = "toggle_dotfiles" },
  { key = "U", action = "toggle_custom" },
  { key = "a", action = "create" },
  { key = "d", action = "remove" },
  { key = "D", action = "trash" },
  { key = "r", action = "rename" },
  { key = "x", action = "cut" },
  { key = "c", action = "copy" },
  { key = "p", action = "paste" },
  { key = "y", action = "copy_name" },
  { key = "Y", action = "copy_path" },
  { key = "gy", action = "copy_absolute_path" },
  { key = "[c", action = "prev_git_item" },
  { key = "]c", action = "next_git_item" },
  { key = "-", action = "dir_up" },
  { key = "s", action = "system_open" },
  { key = "f", action = "live_filter" },
  { key = "F", action = "clear_live_filter" },
  { key = "q", action = "close" },
  { key = "W", action = "collapse_all" },
  { key = "E", action = "expand_all" },
  { key = "S", action = "search_node" },
  { key = "<C-k>", action = "toggle_file_info" },
  { key = "g?", action = "toggle_help" },
  { key = "<BS>", action = "close_node" },
  { key = "R", action = "full_rename" },
  { key = "<C-r>", action = "refresh" },
  { key = ".", action = "toggle_dotfiles" },
  { key = "i", action = "cd" },
  { key = "u", action = "dir_up" },
  { key = "s", action = "vsplit" },
}

nvim_tree.setup({
  update_cwd = true,
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  filters = {
    dotfiles = true,
  },
  view = {
    width = 32,
    mappings = {
      custom_only = true,
      list = mappings,
    },
  },
  git = {
    ignore = true,
    timeout = 500,
  },
  actions = {
    open_file = {
      quit_on_open = true,
      resize_window = true,
      window_picker = {
        enable = false,
      },
    },
  },
})

vim.keymap.set({ "n", "x", "i", "t" }, "<F1>", utils.esc_wrap(nvim_tree.toggle))
