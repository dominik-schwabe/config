-- TODO: fix rapid patch switching
require("project_nvim").setup({
  detection_methods = { "pattern", "lsp" },
  patterns = require("config").root_patterns,
})
