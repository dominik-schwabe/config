require("pluginmappings").setup()
require("plugins")
require("options")
require("custom")
require("color")

local cmd = vim.cmd

cmd("au CmdWinEnter * quit")
cmd("au FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4", false)
cmd("au BufEnter * set fo-=c fo-=r fo-=o", false)
cmd("au TermOpen * setlocal nonumber norelativenumber signcolumn=no filetype=term", false)
cmd("au BufEnter term://* lua EnterTerm()")
cmd("au TermClose term://toggleterm,term://*ripple* lua vim.api.nvim_buf_delete('<abuf>', {force = true})")
