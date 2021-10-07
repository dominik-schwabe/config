local g = vim.g
local cmd = vim.cmd

require('kommentary.config').configure_language('default', {
  prefer_single_line_comments = true,
})

cmd('command! CommentLine execute "normal \\<Plug>kommentary_line_default"')
cmd('command! CommentVisual execute "normal \\<Plug>kommentary_visual_default"')
