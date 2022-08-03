require("todo-comments").setup({
  search = {
    command = "rg",
    args = {
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--max-filesize=1M",
      "--ignore-file",
      ".gitignore",
    },
  },
})

vim.keymap.set({ "n" }, "<space>qt", "<CMD>TodoQuickFix<CR>")
