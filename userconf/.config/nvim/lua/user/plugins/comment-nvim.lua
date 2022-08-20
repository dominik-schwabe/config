require("Comment").setup({
  padding = true,
  sticky = true,
  ignore = "^%s*$",

  mappings = {
    basic = true,
    extra = true,
    extended = true,
  },

  pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
})

-- vim.keymap.set("n", "gc", "<Plug>(comment_toggle_current_linewise)")
-- vim.keymap.set("x", "gc", "<Plug>(comment_toggle_linewise_visual)")
-- vim.keymap.set("n", "gb", "<Plug>(comment_toggle_current_blockwise)")
-- vim.keymap.set("x", "gb", "<Plug>(comment_toggle_blockwise_visual)")
