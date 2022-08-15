require("Comment").setup({
  padding = true,
  sticky = true,
  ignore = "^%s*$",

  mappings = {
    basic = true,
    extra = true,
    extended = true,
  },

  pre_hook = function(ctx)
    -- Only calculate commentstring for tsx filetypes
    if vim.bo.filetype == "typescriptreact" then
      local U = require("Comment.utils")

      -- Determine whether to use linewise or blockwise commentstring
      local type = ctx.ctype == U.ctype.linewise and "__default" or "__multiline"

      -- Determine the location where to calculate commentstring from
      local location = nil
      if ctx.ctype == U.ctype.blockwise then
        location = require("ts_context_commentstring.utils").get_cursor_location()
      elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
        location = require("ts_context_commentstring.utils").get_visual_start_location()
      end

      return require("ts_context_commentstring.internal").calculate_commentstring({
        key = type,
        location = location,
      })
    end
  end,
})

-- vim.keymap.set("n", "gc", "<Plug>(comment_toggle_current_linewise)")
-- vim.keymap.set("x", "gc", "<Plug>(comment_toggle_linewise_visual)")
-- vim.keymap.set("n", "gb", "<Plug>(comment_toggle_current_blockwise)")
-- vim.keymap.set("x", "gb", "<Plug>(comment_toggle_blockwise_visual)")
