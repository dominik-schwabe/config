local config = require("user.config")

local function stopinsert()
  vim.cmd("stopinsert")
end

local actions = require("telescope.actions")
local noop = function() end

require("telescope").setup({
  defaults = {
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ["<F1>"] = noop,
        ["<F3>"] = noop,
        ["<C-p>"] = actions.close,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-c>"] = stopinsert,
        ["<ESC>"] = actions.close,
      },
      n = {
        ["Q"] = function(...)
          actions.close(...)
          vim.cmd("qa")
        end,
        ["<F1>"] = noop,
        ["<F3>"] = noop,
        ["q"] = actions.close,
        ["<C-p>"] = actions.close,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
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
require("telescope").load_extension("custom_buffers")
require("telescope").load_extension("yank_history")
require("telescope").load_extension("macro_history")
require("telescope").load_extension("diffsplit")
