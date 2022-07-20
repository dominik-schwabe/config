require("neo-zoom").setup({
  left_ratio = 0,
  top_ratio = 0,
  width_ratio = 1,
  height_ratio = 1,
  border = "none",
  filetype_exlude = nil,
})

vim.keymap.set({ "n", "x", "i", "t" }, "<F12>", "<CMD>NeoZoomToggle<CR>")