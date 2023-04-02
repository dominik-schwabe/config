local config = require("user.config")

local function stopinsert()
  vim.cmd("stopinsert")
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
    },
    preview = {
      filesize_limit = config.max_buffer_size / (1024 * 1024),
    },
    layout_config = { horizontal = { prompt_position = "top" } },
  },
})
require("telescope").load_extension("yank_history")
require("telescope").load_extension("macro_history")
require("telescope").load_extension("diffsplit")
