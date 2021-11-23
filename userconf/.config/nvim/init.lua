require("color")
require("mappings").setup()
require("plugins")
require("options")
require("custom")

local cmd = vim.cmd

cmd("au CmdWinEnter * quit")
cmd("au FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4", false)
-- cmd("au BufEnter * set fo-=c fo-=r fo-=o", false)
cmd("au TermOpen * setlocal nospell nonumber norelativenumber signcolumn=no filetype=term", false)
cmd("au BufEnter term://* lua EnterTerm()")
cmd("au TermClose term://toggleterm,term://ironrepl call nvim_input('<CR>')")
