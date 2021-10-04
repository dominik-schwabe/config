local map = vim.api.nvim_set_keymap
local g = vim.g

require('kommentary.config').configure_language('default', {
    prefer_single_line_comments = true,
})

require('kommentary.config').configure_language('typescriptreact', {
  single_line_comment_string = 'auto',
  multi_line_comment_strings = 'auto',
  hook_function = function()
    require('ts_context_commentstring.internal').update_commentstring()
  end,
})

g.kommentary_create_default_mappings = false
map('n', 'gc', '<Plug>kommentary_line_default', {silent = true})
map('v', 'gc', '<Plug>kommentary_visual_default', {silent = true})
