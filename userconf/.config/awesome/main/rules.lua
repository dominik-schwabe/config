local awful = require("awful")
local beautiful = require("beautiful")
local clientkeys = require("binding.clientkeys")
local clientbuttons = require("binding.clientbuttons")
local dpi = require("beautiful.xresources").apply_dpi
local f = require("functions")

awful.rules.rules = {
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = function(_client)
        local should_focus = awful.client.focus.filter(_client)
        return should_focus
          and _client.class ~= "TelegramDesktop"
          and _client.class ~= "thunderbird"
          and (_client.class or _client.instance or _client.name) -- Spotify
      end,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen + awful.placement.centered,
    },
  },

  {
    rule_any = {
      instance = {
        "copyq", -- Includes session name in class.
        "pinentry",
        "pavucontrol",
        "matplotlib",
        "r_x11",
        "system-config-printer",
      },
      class = {
        "Arandr",
        "Blueman-manager",
        "Gpick",
        "Kruler",
        "MessageWin", -- kalarm.
        "Sxiv",
        "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
        "Wpa_gui",
        "veromix",
        "xtightvncviewer",
        "Nm-connection-editor",
        "helvum",
        "Nvidia-settings",
      },

      -- Note that the name property shown in xprop might be set slightly after creation of the client
      -- and the name shown there might not match defined rules here.
      name = {
        "Event Tester", -- xev.
      },
      role = {
        "AlarmWindow", -- Thunderbird's calendar.
        "ConfigManager", -- Thunderbird's about:config.
        "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
      },
    },
    properties = {
      floating = true,
      callback = f.client_fix("centered", dpi(800), dpi(500), false),
    },
  },

  {
    rule = {
      class = "TelegramDesktop",
    },
    properties = {
      floating = true,
      callback = f.right,
    },
  },
  {
    rule = {
      class = "Steam",
      name = ".*Steam Guard.*",
    },
    properties = {
      floating = true,
      callback = f.client_fix("center", dpi(800), dpi(500), false),
    },
  },
  {
    rule = {
      class = "Steam",
      name = "Steam - .*",
    },
    properties = {
      floating = true,
      callback = f.client_fix("center", dpi(800), dpi(500), false),
    },
  },
  {
    rule = {
      instance = "Places",
      class = "firefox",
    },
    properties = {
      floating = true,
      callback = f.client_fix("center", dpi(800), dpi(500), false),
    },
  },
  {
    rule = {
      instance = "Toolkit",
      class = "firefox",
    },
    properties = {
      floating = true,
      callback = f.client_fix("center", dpi(800), dpi(500), false),
    },
  },
  {
    rule = {
      instance = "Msgcompose",
      class = "Thunderbird",
    },
    properties = {
      floating = true,
      callback = f.client_fix("center", dpi(800), dpi(500), false),
    },
  },
  {
    rule = { name = "Figure *", class = " " },
    properties = {
      floating = true,
      callback = f.client_fix("center", dpi(800), dpi(500), false),
    },
  },

  -- Add titlebars to normal clients and dialogs
  {
    rule_any = {
      type = { "normal", "dialog" },
    },
    properties = {
      titlebars_enabled = false,
    },
  },

  {
    rule_any = { class = "Brave-browser", "firefox" },
    properties = {
      screen = 1,
      tag = "1",
      callback = awful.client.focus.history.add,
    },
  },
  {
    rule_any = {
      name = { "^Steam$" },
      class = { "Steam" },
    },
    properties = {
      screen = 1,
      tag = "3",
      callback = awful.client.focus.history.add,
    },
  },
  {
    rule = { class = "steam_app" },
    properties = {
      screen = 1,
      tag = "4",
      callback = awful.client.focus.history.add,
    },
  },
  {
    rule = { class = "discord" },
    properties = {
      screen = 1,
      tag = "7",
      callback = awful.client.focus.history.add,
    },
  },
  {
    rule_any = { class = { "Slay the Spire" } },
    properties = {
      size_hints_honor = false,
      fullscreen = true,
    },
  },
  {
    rule_any = { class = { "mpv" } },
    properties = {
      size_hints_honor = false,
    },
  },
}
