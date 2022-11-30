require("tmux").setup({
  copy_sync = {
    enable = true,
    redirect_to_clipboard = true,
    sync_clipboard = false,
    sync_deletes = true,
    sync_unnamed = true,
  },
  navigation = { enable_default_keybindings = false },
})
