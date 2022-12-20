local naughty = require("naughty")

local theme = require("theme")

naughty.config.defaults.margin = theme.notification_margin
naughty.config.defaults.border_width = theme.notification_border_width
naughty.config.defaults.screen = 1

local M = {}

function M.error(text, title)
  naughty.notify({
    preset = { fg = "#FF0000", bg = "#000000", timeout = 0, border_color = "#FF0000" },
    text = text,
    title = title,
  })
end

function M.info(text, timeout)
  timeout = timeout or 5
  naughty.notify({
    text = text,
    timeout = timeout,
  })
end

return M
