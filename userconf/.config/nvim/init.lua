require("myconfig.plugins")
require("myconfig.color")
require("myconfig.mappings").setup()
require("myconfig.options")
require("myconfig.custom")

local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

function TermDelete()
  api.nvim_buf_delete(fn.expand("<abuf>"), { force = true })
end

cmd("au CmdWinEnter * quit")
cmd("au FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4", false)
-- cmd("au BufEnter * set fo-=c fo-=r fo-=o", false)
cmd("au TermOpen * setlocal nospell nonumber norelativenumber signcolumn=no filetype=term", false)
cmd("au BufEnter term://* lua EnterTerm()")
-- cmd("au TermClose term://toggleterm,term://ironrepl call nvim_input('<CR>')")
cmd("au TermClose term://toggleterm,term://ironrepl lua TermDelete()")

require("myconfig.plugins.colorizer")
