local cmd = vim.cmd

local function stopinsert()
  cmd("stopinsert")
end
require("telescope").load_extension("projects")
require("telescope").setup({
  defaults = {
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ["<C-p>"] = require("telescope.actions").close,
        ["<F11>"] = require("telescope.actions").close,
        ["<C-c>"] = stopinsert,
        ["<ESC>"] = require("telescope.actions").close,
      },
      n = {
        ["<C-p>"] = require("telescope.actions").close,
        ["<F11>"] = require("telescope.actions").close,
      },
    },
    layout_config = { horizontal = { prompt_position = "top" } },
  },
})
