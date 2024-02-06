vim.loader.enable()

require("user.globals")
require("user.options")
require("user.plugins")
require("user.custom")
require("user.mappings")
require("user.autocmds")

vim.cmd("colorscheme monokai-rainbow")
