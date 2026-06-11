vim.loader.enable()
require("vim._core.ui2").enable({})

require("user.globals")
require("user.options")
require("user.plugins")
require("user.custom")
require("user.mappings")
require("user.autocmds")

vim.cmd.packadd("nvim.undotree")
vim.cmd.colorscheme("monokai-rainbow")
