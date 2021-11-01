notify = require("notify")

notify.setup({
  stages = "static",
  on_open = nil,
  timeout = 3000,
  background_colour = "#000000",
  icons = {
    ERROR = "",
    WARN = "",
    INFO = "",
    DEBUG = "",
    TRACE = "✎",
  },
})

vim.notify = notify
