local awful = require("awful")

local layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.max,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.fair,
  awful.layout.suit.floating,
  awful.layout.suit.magnifier,
  awful.layout.suit.spiral.dwindle,
}

return layouts
