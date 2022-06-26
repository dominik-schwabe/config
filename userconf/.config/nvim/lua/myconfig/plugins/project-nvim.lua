local config = require("myconfig.config")

require("project_nvim").setup({
  patterns = config.root_patterns,
  detection_methods = { "pattern", "lsp" }
})
