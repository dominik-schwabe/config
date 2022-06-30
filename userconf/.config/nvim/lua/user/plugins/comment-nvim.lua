require("Comment").setup({
  padding = true,
  sticky = true,
  ignore = "^%s*$",

  mappings = {
    basic = false,
    extra = false,
    extended = false,
  },

  pre_hook = function(ctx)
    local U = require("Comment.utils")

    local location = nil
    if ctx.ctype == U.ctype.block then
      location = require("ts_context_commentstring.utils").get_cursor_location()
    elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
      location = require("ts_context_commentstring.utils").get_visual_start_location()
    end

    return require("ts_context_commentstring.internal").calculate_commentstring({
      key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
      location = location,
    })
  end,
})

vim.keymap.set("n", "gc", "<Plug>(comment_toggle_current_linewise)")
vim.keymap.set("x", "gc", "<Plug>(comment_toggle_linewise_visual)")
vim.keymap.set("n", "gb", "<Plug>(comment_toggle_current_blockwise)")
vim.keymap.set("x", "gb", "<Plug>(comment_toggle_blockwise_visual)")
