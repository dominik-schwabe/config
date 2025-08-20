from __future__ import annotations

import asyncio
import re
from collections.abc import Sequence
from typing import Any

from libqtile.config import Group, Match
from libqtile.core.manager import Qtile
from libqtile.lazy import lazy

from qtile_user.cmd import Cmd, CmdChord
from qtile_user.config import GUIFILEBROWSER, MODKEY, PLAYERCTL, TERMINAL, WEBBROWSER
from qtile_user.dimension import Relative, move_floating, place
from qtile_user.spawn import cmd, sh
from qtile_user.sticky import current_window, get_qtile, make_sticky, toggle_sticky_windows

PROCESSES: dict[str, asyncio.subprocess.Process] = {}


async def toggler(_: Any, cmd: str):
    if (process := PROCESSES.get(cmd)) is not None and process.returncode is None:
        process.kill()
    else:
        PROCESSES[cmd] = await asyncio.create_subprocess_exec(cmd)


def lazy_toggler(cmd: str):
    return lazy.function(toggler, cmd)


mod = [MODKEY]
mod_s = [MODKEY, "shift"]
mod_c = [MODKEY, "control"]


def brightness_cmd(percentage: int, *keys: str | int | tuple[Sequence[str], str | int]):
    fmt = f"{abs(percentage)}%"
    fmt = f"+{fmt}" if percentage > 0 else f"{fmt}-"
    return Cmd(*keys, cmd=cmd(["brightnessctl", "set", fmt]), desc=f"Screen brightness {percentage}%")


# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
vt_cmds: list[Cmd | CmdChord] = [
    Cmd(
        (["control", "mod1"], f"f{vt}"),
        cmd=lazy.core.change_vt(vt).when(func=lambda: get_qtile().core.name == "wayland"),
        desc=f"Switch to VT{vt}",
    )
    for vt in range(1, 8)
]


audio_keys: list[Cmd | CmdChord] = [
    Cmd("XF86AudioLowerVolume", (mod, "m"), cmd=cmd(["pamixer", "-d", "5"]), desc="Decrease volume by 5%"),
    Cmd("XF86AudioRaiseVolume", (mod_s, "m"), cmd=cmd(["pamixer", "-i", "5"]), desc="Increase volume by 5%"),
    Cmd("XF86AudioPrev", (mod, "less"), cmd=cmd([*PLAYERCTL, "previous"]), desc="Play the previous track"),
    Cmd("XF86AudioNext", (mod, "x"), cmd=cmd([*PLAYERCTL, "next"]), desc="Play the next track"),
    Cmd("XF86AudioPlay", (mod, "y"), cmd=cmd([*PLAYERCTL, "play-pause"]), desc="Start/Stop the audio"),
    Cmd("XF86AudioStop", cmd=cmd([*PLAYERCTL, "pause"]), desc="Stop the audio"),
    Cmd("XF86AudioMute", cmd=cmd(["pamixer", "--toggle-mute"]), desc="Toggle speaker mute"),
    Cmd("XF86AudioMicMute", cmd=cmd(["toggle_microphone_mute", "pci"]), desc="Toggle pci microphone mute"),
    CmdChord(
        (mod, "comma"),
        cmds=[
            Cmd("u", cmd=cmd(["toggle_microphone_mute", "usb"]), desc="Toggle usb microphone mute"),
            Cmd("a", cmd=lazy_toggler("auto_clicker"), desc="Toggle auto clicker"),
            Cmd("i", cmd=lazy.group["dropdown"].dropdown_toggle("image-viewer"), desc="Toggle image viewer"),
        ],
        name=",",
    ),
]


def resize(
    qtile: Qtile,
    width: float,
    height: float,
):
    if (window := current_window(qtile)) is not None:
        place(
            window,
            qtile.current_screen,
            width=Relative(width),
            height=Relative(height),
        )


lazy_resize = lazy.function(resize)


def fix_pos(
    qtile: Qtile,
    x: float,
    y: float,
    width: float,
    height: float,
    *,
    sticky_delta: float | None = None,
    stick: bool = False,
):
    if (window := current_window(qtile)) is not None:
        place(
            window,
            qtile.current_screen,
            x=Relative(x, "fixed"),
            y=Relative(y, "fixed"),
            width=Relative(width, "fixed"),
            height=Relative(height, "fixed"),
            sticky_delta=sticky_delta,
        )
        if stick:
            make_sticky(window)


lazy_fix_pos = lazy.function(fix_pos)


def grow(qtile: Qtile, width: float, height: float):
    if (window := current_window(qtile)) is not None:
        place(
            window,
            qtile.current_screen,
            x=Relative(min(width, 0)),
            y=Relative(min(height, 0)),
            width=Relative(abs(width)),
            height=Relative(abs(height)),
            sticky_delta=None,
        )


lazy_grow = lazy.function(grow)


def lazy_fix_center(width: float, height: float):
    return lazy_fix_pos((1 - width) / 2, (1 - height) / 2, width, height)


cmds: list[Cmd | CmdChord] = [
    *vt_cmds,
    *audio_keys,
    brightness_cmd(-1, (mod, "F2")),
    brightness_cmd(1, (mod, "F3")),
    brightness_cmd(-5, ([], "XF86MonBrightnessDown")),
    brightness_cmd(5, ([], "XF86MonBrightnessUp")),
    Cmd("XF86Display", cmd=cmd("~/.bin/nolidswitch"), desc="Toggle prevent supend"),
    Cmd((mod_s, "s"), cmd=sh("playerctl -a pause ; exec i3lock -c 222222"), desc="Lock the screen"),
    Cmd(
        (mod, "h"),
        cmd=[
            lazy.layout.left().when(layout=["monadtall"]),
            lazy.layout.previous().when(layout="max"),
        ],
        desc="Move focus to left",
    ),
    Cmd(
        (mod, "l"),
        cmd=[
            lazy.layout.right().when(layout=["monadtall"]),
            lazy.layout.next().when(layout="max"),
        ],
        desc="Move focus to right",
    ),
    Cmd((mod, "j"), cmd=lazy.layout.down(), desc="Move focus down"),
    Cmd((mod, "k"), cmd=lazy.layout.up(), desc="Move focus up"),
    Cmd(
        (mod_s, "h"),
        cmd=[
            lazy.layout.shuffle_left().when(when_floating=False),
            move_floating(-64, 0).when(when_floating=True),
        ],
        desc="Move window to the left",
    ),
    Cmd(
        (mod_s, "l"),
        cmd=[
            lazy.layout.shuffle_right().when(when_floating=False),
            move_floating(64, 0).when(when_floating=True),
        ],
        desc="Move window to the right",
    ),
    Cmd(
        (mod_s, "j"),
        cmd=[
            lazy.layout.shuffle_down().when(when_floating=False),
            move_floating(0, 64).when(when_floating=True),
        ],
        desc="Move window down",
    ),
    Cmd(
        (mod_s, "k"),
        cmd=[
            lazy.layout.shuffle_up().when(when_floating=False),
            move_floating(0, -64).when(when_floating=True),
        ],
        desc="Move window up",
    ),
    Cmd((mod_c, "h"), cmd=lazy.layout.grow_left(), desc="Grow window to the left"),
    Cmd((mod_c, "l"), cmd=lazy.layout.grow_right(), desc="Grow window to the right"),
    Cmd((mod_c, "j"), cmd=lazy.layout.grow_down(), desc="Grow window down"),
    Cmd((mod_c, "k"), cmd=lazy.layout.grow_up(), desc="Grow window up"),
    Cmd((mod_s, "plus"), cmd=lazy.layout.grow(), desc="Increase the current window"),
    Cmd((mod_s, "minus"), cmd=lazy.layout.shrink(), desc="Decrease the space for master window"),
    Cmd((mod_s, "0"), cmd=lazy.layout.reset(), desc="Reset all window sizes"),
    Cmd((mod, "e"), cmd=lazy.group.setlayout("monadtall"), desc="MonadTall layout"),
    Cmd((mod, "w"), cmd=lazy.group.setlayout("max"), desc="Max layout"),
    # Cmd((mod_s, "Return"), cmd=lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),
    Cmd((mod, "Return"), cmd=cmd([TERMINAL]), desc=f"Launch {TERMINAL}"),
    Cmd((mod_s, "Return"), cmd=cmd([GUIFILEBROWSER]), desc=f"Launch {GUIFILEBROWSER}"),
    Cmd((mod, "Print"), cmd=cmd(["screenshot", "-s"]), desc="Take a screenshot of the entire screen"),
    Cmd((mod_s, "Print"), cmd=cmd(["screenshot", "-w"]), desc="Take a screenshot of the focused window"),
    Cmd((mod, "d"), cmd=cmd(["rofi", "-show", "drun", "-dpi", "150"]), desc="Launch launcher"),
    Cmd((mod, "c"), cmd=cmd(["pick_color"]), desc="Launch launcher"),
    Cmd((mod, "Delete"), cmd=lazy_toggler("xkill"), desc="Toggle window terminator"),
    Cmd((mod, "Tab"), cmd=lazy.screen.toggle_group(), desc="Toggle between layouts"),
    Cmd((mod_s, "q"), cmd=lazy.window.kill(), desc="Kill focused window"),
    Cmd((mod, "f"), cmd=lazy.window.toggle_fullscreen(), desc="Toggle fullscreen on the focused window"),
    Cmd((mod_s, "space"), cmd=lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Cmd((mod_s, "r"), cmd=lazy.restart(), desc="Restart Qtile"),
    Cmd((mod_s, "Delete"), cmd=lazy.shutdown(), desc="Shutdown Qtile"),
    # Cmd((mod, "r"), cmd=lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Cmd(
        (mod, "asciicircum"),
        cmd=lazy.group["dropdown"].dropdown_toggle("dropdown-terminal"),
        desc="Toggle dropdown terminal",
    ),
    Cmd(
        (mod_s, "y"),
        cmd=lazy.group["dropdown"].dropdown_toggle("music-player"),
        desc="Toggle music player",
    ),
    Cmd(
        (mod, "odiaeresis"),
        cmd=[
            sh(f"pgrep -u $UID {WEBBROWSER} || {WEBBROWSER}"),
            lazy.group["1"].toscreen(),
        ],
        desc="Focus the webbrowser screen",
    ),
    Cmd((mod, "s"), cmd=toggle_sticky_windows(), desc="Toggle sticky"),
    Cmd((mod, "plus"), cmd=lazy_resize(0.1, 0.1).when(when_floating=True), desc="Increase size of the float"),
    Cmd((mod, "minus"), cmd=lazy_resize(-0.1, -0.1).when(when_floating=True), desc="Decrease size of the float"),
    Cmd((mod, "i"), cmd=lazy_fix_pos(0, 1, 0.3, 0.3, stick=True), desc="Fix bottom-left"),
    Cmd((mod, "o"), cmd=lazy_fix_pos(1, 1, 0.3, 0.3, stick=True), desc="Fix bottom-right"),
    Cmd((mod_s, "i"), cmd=lazy_fix_pos(0, 0, 0.3, 0.3, stick=True), desc="Fix top-left"),
    Cmd((mod_s, "o"), cmd=lazy_fix_pos(1, 0, 0.3, 0.3, stick=True), desc="Fix top-right"),
    Cmd((mod, "period"), cmd=lazy_fix_center(0.85, 0.85), desc="Fix center"),
    Cmd((mod, "Down"), cmd=lazy_fix_pos(0, 0.5, 1, 0.5), desc="Align the window to the bottom"),
    Cmd((mod, "Up"), cmd=lazy_fix_pos(0, 0, 1, 0.5), desc="Align the window to the top"),
    Cmd((mod, "Left"), cmd=lazy_fix_pos(0, 0, 0.5, 1), desc="Align the window to the left"),
    Cmd((mod, "Right"), cmd=lazy_fix_pos(0.5, 0, 0.5, 1), desc="Align the window to the right"),
    Cmd((mod_s, "Down"), cmd=lazy_grow(0, 0.1), desc="Grow the window to the bottom"),
    Cmd((mod_s, "Up"), cmd=lazy_grow(0, -0.1), desc="Grow the window to the top"),
    Cmd((mod_s, "Left"), cmd=lazy_grow(-0.1, 0), desc="Grow the window to the left"),
    Cmd((mod_s, "Right"), cmd=lazy_grow(0.1, 0), desc="Grow the window to the right"),
]


GROUPS = [
    Group(
        "1",
        matches=[
            Match(wm_class="brave-browser"),
        ],
    ),
    Group("2"),
    Group(
        "3",
        matches=[
            Match(wm_class="Steam"),
        ],
    ),
    Group(
        "4",
        matches=[
            Match(wm_class=re.compile("^steam_app.*$")),
        ],
    ),
    Group("5"),
    Group("6"),
    Group(
        "7",
        layout="max",
        matches=[
            Match(wm_class="Spotify"),
            Match(wm_class="Mail"),
            Match(wm_class="discord"),
            Match(wm_class="Skype"),
        ],
    ),
]

for i in GROUPS:
    cmds.extend(
        [
            Cmd((mod, i.name), cmd=lazy.group[i.name].toscreen(), desc=f"Switch to group {i.name}"),
            Cmd(
                (mod_s, i.name),
                cmd=lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
        ]
    )

last = GROUPS[-1]
cmds.append(Cmd((mod, "p"), cmd=lazy.group[last.name].toscreen(), desc=f"Switch to group {last.name}"))

KEYS = [key for cmd in cmds for key in cmd.to_keys()]
