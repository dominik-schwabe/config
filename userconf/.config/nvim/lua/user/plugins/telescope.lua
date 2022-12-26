local cmd = vim.cmd

local function stopinsert()
  cmd("stopinsert")
end

require("telescope").setup({
  defaults = {
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ["<C-p>"] = require("telescope.actions").close,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-c>"] = stopinsert,
        ["<ESC>"] = require("telescope.actions").close,
      },
      n = {
        ["<C-p>"] = require("telescope.actions").close,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<C-j>"] = require("telescope.actions").move_selection_next,
      },
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--ignore-case",
      "--max-filesize=1M",
      "--ignore-file",
      ".gitignore",
    },
    layout_config = { horizontal = { prompt_position = "top" } },
  },
})
require("telescope").load_extension("yank_history")
require("telescope").load_extension("macro_history")
require("telescope").load_extension("diffsplit")

vim.keymap.set({ "n", "x", "i" }, "<C-p>", "<CMD>Telescope find_files<CR>")
vim.keymap.set({ "n", "x" }, "_", "<CMD>Telescope live_grep<CR>")
vim.keymap.set("n", "z=", "<CMD>Telescope spell_suggest<CR><ESC>")
vim.keymap.set({ "n", "x" }, "<space>/", "<CMD>Telescope current_buffer_fuzzy_find<CR>")
vim.keymap.set({ "n", "x" }, "<space>h", "<CMD>Telescope help_tags<CR>")
vim.keymap.set({ "n", "x" }, "<space>,,", "<CMD>Telescope resume<CR>")
vim.keymap.set({ "n", "x" }, "<space>,k", "<CMD>Telescope keymaps<CR>")
vim.keymap.set({ "n", "x" }, "<space>,j", "<CMD>Telescope jumplist<CR>")
vim.keymap.set({ "n", "x" }, "<space>,y", "<CMD>Telescope yank_history<CR>")
vim.keymap.set({ "n", "x" }, "<space>,q", "<CMD>Telescope macro_history<CR>")
vim.keymap.set({ "n", "x" }, "<space>,d", "<CMD>Telescope diffsplit<CR>")
vim.keymap.set({ "n", "x" }, "<space>,s", "<CMD>Telescope git_status<CR>")
