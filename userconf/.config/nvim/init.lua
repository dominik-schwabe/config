require("myconfig.plugins")
require("myconfig.mappings").setup()
require("myconfig.options")
require("myconfig.custom")

vim.api.nvim_create_autocmd("CmdWinEnter", {
  command = "quit",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  command = "setlocal tabstop=4 shiftwidth=4 softtabstop=4",
})
-- cmd("au BufEnter * set fo-=c fo-=r fo-=o", false)

vim.cmd("colorscheme monokai")
require("myconfig.plugins.colorizer")
