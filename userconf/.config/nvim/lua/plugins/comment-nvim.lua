local cmd = vim.cmd

require('Comment').setup({
    padding = true,
    sticky = true,

    mappings = {
        basic = false,
        extra = false,
        extended = false,
    },
})

cmd('command! Comment lua require("Comment.api").gcc("char")')
