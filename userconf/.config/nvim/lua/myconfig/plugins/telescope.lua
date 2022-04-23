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
