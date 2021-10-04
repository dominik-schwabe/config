-- TODO: fix rapid patch switching
require("project_nvim").setup({
  detection_methods = { "lsp", "pattern" },
  patterns = require("config").root_patterns,
})
