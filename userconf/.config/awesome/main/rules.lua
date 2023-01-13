local awful = require("awful")
local beautiful = require("beautiful")
local clientkeys = require("binding.clientkeys")
local clientbuttons = require("binding.clientbuttons")
local dpi = require("beautiful.xresources").apply_dpi
local f = require("functions")

local dialog_placement = awful.placement.centered + awful.placement.no_offscreen
local normal_placement = awful.placement.centered + awful.placement.no_overlap + awful.placement.no_offscreen

local function default_placement(c)
  if c.type == "normal" then
    normal_placement(c)
  else
    dialog_placement(c)
  end
end

local function spawn_no_overlap(c)
  c.floating = true
  f.set_geometry(c, { honor_workarea = true, width = dpi(800), height = dpi(500) })
  default_placement(c)
end

local float_properties = {
  floating = true,
  callback = spawn_no_overlap,
}

local function assign(tag_name)
  return {
    screen = 1,
    tag = tag_name,
  }
end

awful.rules.rules = {
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = function(c)
        local should_focus = awful.client.focus.filter(c)
        return should_focus
          and c.class ~= "TelegramDesktop"
          and c.class ~= "thunderbird"
          and (c.class or c.instance or c.name) -- Spotify
      end,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = default_placement,
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
    properties = float_properties,
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
    properties = float_properties,
  },
  {
    rule = {
      class = "Steam",
      name = "Steam - .*",
    },
    properties = float_properties,
  },
  {
    rule = {
      instance = "Places",
      class = "firefox",
    },
    properties = float_properties,
  },
  {
    rule = {
      instance = "Toolkit",
      class = "firefox",
    },
    properties = float_properties,
  },
  {
    rule = {
      instance = "Msgcompose",
      class = "Thunderbird",
    },
    properties = float_properties,
  },
  {
    rule = { name = "Figure *", class = " " },
    properties = float_properties,
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
    rule_any = { class = { "Brave-browser", "firefox" } },
    properties = assign("1"),
  },
  {
    rule_any = {
      name = { "^Steam$" },
      class = { "Steam" },
    },
    properties = assign("3"),
  },
  {
    rule = { class = "steam_app" },
    properties = assign("4"),
  },
  {
    rule = { class = "discord" },
    properties = assign("7"),
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
  {
    rule = {},
    callback = function(c)
      if c.height <= 60 then
        awful.placement.align(c, {
          position = "bottom",
          margins = -30,
        })
      end
    end,
  },
}
