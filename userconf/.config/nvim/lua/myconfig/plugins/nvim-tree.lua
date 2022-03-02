local g = vim.g

local cb = require("nvim-tree.config").nvim_tree_callback
local mappings = {
  { key = { "<CR>", "o", "<2-LeftMouse>" }, cb = cb("edit") },
  { key = { "<2-RightMouse>", "<C-]>" }, cb = cb("cd") },
  { key = "<C-v>", cb = cb("vsplit") },
  { key = "<C-x>", cb = cb("split") },
  { key = "<C-t>", cb = cb("tabnew") },
  { key = "<", cb = cb("prev_sibling") },
  { key = ">", cb = cb("next_sibling") },
  { key = "P", cb = cb("parent_node") },
  { key = "<BS>", cb = cb("close_node") },
  { key = "<S-CR>", cb = cb("close_node") },
  { key = "<Tab>", cb = cb("preview") },
  { key = "K", cb = cb("first_sibling") },
  { key = "J", cb = cb("last_sibling") },
  { key = "I", cb = cb("toggle_ignored") },
  { key = "H", cb = cb("toggle_dotfiles") },
  { key = "R", cb = cb("full_rename") },
  { key = "a", cb = cb("create") },
  { key = "d", cb = cb("remove") },
  { key = "r", cb = cb("rename") },
  { key = "<C-r>", cb = cb("refresh") },
  { key = "x", cb = cb("cut") },
  { key = "c", cb = cb("copy") },
  { key = "p", cb = cb("paste") },
  { key = "y", cb = cb("copy_name") },
  { key = "Y", cb = cb("copy_path") },
  { key = "gy", cb = cb("copy_absolute_path") },
  { key = "[c", cb = cb("prev_git_item") },
  { key = "]c", cb = cb("next_git_item") },
  { key = "s", cb = cb("system_open") },
  { key = "q", cb = cb("close") },
  { key = "g?", cb = cb("toggle_help") },
  { key = ".", cb = cb("toggle_dotfiles") },
  { key = "i", cb = cb("cd") },
  { key = "u", cb = cb("dir_up") },
  { key = "s", cb = cb("vsplit") },
}

require("nvim-tree").setup({
  disable_window_picker = 1,
  auto_close = false,
  hijack_cursor = false,
  update_cwd = true,
  disable_netrw = false,
  hijack_netrw = true,
  update_to_buf_dir = {
    enable = true,
    auto_open = true,
  },
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
    enabled = true,
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
