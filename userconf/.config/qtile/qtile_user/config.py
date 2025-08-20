from __future__ import annotations

import os
from pathlib import Path

HOME = Path.home()
EDITOR = os.getenv("EDITOR") or "vim"
WEBBROWSER = os.getenv("BROWSER") or "brave"
TERMINAL = "wezterm"
MODKEY = "mod4"
EDITOR_CMD = f"{TERMINAL} -e {EDITOR}"
WALLPAPER = HOME / ".bg.jpeg"
PLAYERCTL = ["playerctl", "--player", "spotify,cmus,chromium"]
GUIFILEBROWSER = "thunar"
