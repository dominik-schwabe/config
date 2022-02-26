require("nvim-rooter").setup({
  rooter_patterns = require("myconfig.config").root_patterns,
  trigger_patterns = { "*" },
  manual = false,
})
