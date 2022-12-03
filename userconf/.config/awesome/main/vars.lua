local home = os.getenv("HOME")
local editor = os.getenv("EDITOR") or "vim"
local webbrowser = os.getenv("BROWSER") or "brave"
local terminal = "alacritty"

local M = {
  home = home,
  terminal = terminal,
  editor = editor,
  editor_cmd = terminal .. " -e " .. editor,
  modkey = "Mod4",
  wallpaper = home .. "/.bg.jpg",
  shell = "bash",
  playerctl = "playerctl --player spotify,cmus,chromium",
  guifilebrowser = "thunar",
  compositor = "picom",
  webbrowser = webbrowser,
}

return M
