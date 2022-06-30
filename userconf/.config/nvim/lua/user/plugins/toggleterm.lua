require("toggleterm").setup({
  size = 10,
  hide_numbers = true,
  shade_filetypes = {},
  -- highlights = {
  --   Normal = {
  --     guibg = "<VALUE-HERE>",
  --   },
  --   NormalFloat = {
  --     link = 'Normal'
  --   },
  --   FloatBorder = {
  --     guifg = "<VALUE-HERE>",
  --     guibg = "<VALUE-HERE>",
  --   },
  -- },
  start_in_insert = true,
  insert_mappings = true,
  terminal_mappings = true,
  persist_size = false,
  persist_mode = true,
  direction = 'horizontal',
  close_on_exit = true,
})

vim.keymap.set({ "n", "x", "t" }, "<F10>", "<CMD>ToggleTerm 1<CR>")
vim.keymap.set("i", "<F10>", "<ESC>:ToggleTerm 1<CR>")
vim.keymap.set({ "n", "x", "t" }, "<F22>", "<CMD>ToggleTermRight<CR>")
vim.keymap.set("i", "<F22>", "<ESC>:ToggleTermRight<CR>")
