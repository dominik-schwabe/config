local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local beautiful = require("beautiful")
local vars = require("main.vars")

local function hotkeys()
  hotkeys_popup.show_help(nil, awful.screen.focused())
end

local function quit()
  awesome.quit()
end

local awesome_menu = {
  { "hotkeys", hotkeys },
  { "manual", vars.terminal .. " -e man awesome" },
  { "edit config", vars.editor_cmd .. " " .. awesome.conffile },
  { "Terminal", vars.terminal },
  { "Shutdown/Logout", "oblogout" },
  { "restart", awesome.restart },
  { "quit", quit },
}

local favorite = {
  { "caja", "caja" },
  { "thunar", "thunar" },
  { "geany", "geany" },
  { "clementine", "clementine" },
  { "firefox", "firefox", awful.util.getdir("config") .. "/firefox.png" },
  { "chromium", "chromium" },
  { "&firefox", "firefox" },
  { "&thunderbird", "thunderbird" },
  { "libreoffice", "libreoffice" },
  { "transmission", "transmission-gtk" },
  { "gimp", "gimp" },
  { "inkscape", "inkscape" },
  { "screenshooter", "xfce4-screenshooter" },
}

local network_main = {
  { "wicd-curses", "wicd-curses" },
  { "wicd-gtk", "wicd-gtk" },
}

local menu = awful.menu({
  items = {
    { "awesome", awesome_menu, beautiful.awesome_subicon },
    { "open terminal", vars.terminal },
    { "network", network_main },
    { "favorite", favorite },
  },
})

return menu
