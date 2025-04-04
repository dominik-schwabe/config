from __future__ import annotations

import os
from pathlib import Path
from typing import Sequence

from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, KeyChord, Match, Screen
from libqtile.lazy import LazyCall, lazy

mod_key = "mod4"
mod = [mod_key]
mod_s = [mod_key, "shift"]
mod_c = [mod_key, "control"]

home = Path.home()
editor = os.getenv("EDITOR") or "vim"
webbrowser = os.getenv("BROWSER") or "brave"
terminal = "wezterm"

editor_cmd = f"{terminal} -e {editor}"
wallpaper = home / ".bg.jpeg"
playerctl = ["playerctl", "--player", "spotify,cmus,chromium"]
guifilebrowser = "thunar"
webbrowser = webbrowser


def cmd(cmd: str | list[str]) -> LazyCall:
    return lazy.spawn(cmd)


def sh(cmd: str | list[str]) -> LazyCall:
    return lazy.spawn(cmd, shell=True)


class Cmd:
    def __init__(
        self,
        *keys: str | int | tuple[Sequence[str], str | int],
        cmd: LazyCall | Sequence[LazyCall],
        desc: str = "",
        swallow: bool = True,
    ):
        self.bindings: list[tuple[Sequence[str], str | int]] = [
            (([], e) if isinstance(e, str | int) else e) for e in keys
        ]
        self.commands = cmd if isinstance(cmd, Sequence) else [cmd]
        self.desc = desc
        self.swallow = swallow

    def to_keys(self) -> list[Key]:
        return [
            Key(list(modifiers), key, *self.commands, desc=self.desc, swallow=self.swallow)
            for modifiers, key in self.bindings
        ]


class CmdChord:
    def __init__(
        self,
        keys: tuple[Sequence[str], str | int],
        *,
        cmds: Cmds,
        mode: bool | str = False,
        name: str = "",
        desc: str = "",
        swallow: bool = True,
    ):
        self.keys = keys
        self.cmds = cmds
        self.mode = mode
        self.name = name
        self.desc = desc
        self.swallow = swallow

    def to_keys(self) -> list[KeyChord]:
        modifiers, key = self.keys
        return [
            KeyChord(
                list(modifiers),
                key,
                [key for cmd in self.cmds for key in cmd.to_keys()],
                mode=self.mode,
                name=self.name,
                desc=self.desc,
                swallow=self.swallow,
            )
        ]


Cmds = Sequence[Cmd | CmdChord]


def brightness_cmd(percentage: int, *keys: str | int | tuple[Sequence[str], str | int]):
    percent = f"+{percentage}%" if percentage > 0 else f"{percentage}%-"
    return Cmd(*keys, cmd=cmd(["brightnessctl", "set", percent]), desc=f"Screen brightness {percent}%")


# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
vt_cmds: Cmds = [
    Cmd(
        (["control", "mod1"], f"f{vt}"),
        cmd=lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
        desc=f"Switch to VT{vt}",
    )
    for vt in range(1, 8)
]


audio_keys: Cmds = [
    Cmd("XF86AudioRaiseVolume", (mod, "m"), cmd=cmd("pamixer -i 5"), desc="Increase volume by 5%"),
    Cmd("XF86AudioLowerVolume", (mod, "n"), cmd=cmd("pamixer -d 5"), desc="Decrease volume by 5%"),
    Cmd("XF86AudioPrev", (mod, "less"), cmd=cmd([*playerctl, "previous"]), desc="Play the previous track"),
    Cmd("XF86AudioNext", (mod, "x"), cmd=cmd([*playerctl, "next"]), desc="Play the next track"),
    Cmd("XF86AudioPlay", (mod, "y"), cmd=cmd([*playerctl, "play-pause"]), desc="Start/Stop the audio"),
    Cmd("XF86AudioStop", cmd=cmd([*playerctl, "pause"]), desc="Stop the audio"),
    Cmd("XF86AudioMute", cmd=cmd(["pamixer", "--toggle-mute"]), desc="Toggle speaker mute"),
    Cmd("XF86AudioMicMute", cmd=cmd(["toggle_microphone_mute", "pci"]), desc="Toggle pci microphone mute"),
    CmdChord(
        (mod, "comma"),
        cmds=[
            Cmd("u", cmd=cmd(["toggle_microphone_mute", "usb"]), desc="Toggle usb microphone mute"),
        ],
        name="A",
    ),
]


cmds: Cmds = [
    *vt_cmds,
    *audio_keys,
    brightness_cmd(-1, (mod, "F2")),
    brightness_cmd(1, (mod, "F3")),
    brightness_cmd(-5, (mod, "XF86MonBrightnessDown")),
    brightness_cmd(5, (mod, "XF86MonBrightnessUp")),
    Cmd("XF86Display", cmd=cmd("~/.bin/nolidswitch"), desc="Toggle prevent supend"),
    Cmd((mod_s, "s"), cmd=sh("playerctl -a pause ; exec i3lock -c 222222"), desc="Lock the screen"),
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Cmd((mod, "h"), cmd=lazy.layout.left(), desc="Move focus to left"),
    Cmd((mod, "l"), cmd=lazy.layout.right(), desc="Move focus to right"),
    Cmd((mod, "j"), cmd=lazy.layout.down(), desc="Move focus down"),
    Cmd((mod, "k"), cmd=lazy.layout.up(), desc="Move focus up"),
    Cmd((mod, "space"), cmd=lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Cmd((mod_s, "h"), cmd=lazy.layout.shuffle_left(), desc="Move window to the left"),
    Cmd((mod_s, "l"), cmd=lazy.layout.shuffle_right(), desc="Move window to the right"),
    Cmd((mod_s, "j"), cmd=lazy.layout.shuffle_down(), desc="Move window down"),
    Cmd((mod_s, "k"), cmd=lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Cmd((mod_c, "h"), cmd=lazy.layout.grow_left(), desc="Grow window to the left"),
    Cmd((mod_c, "l"), cmd=lazy.layout.grow_right(), desc="Grow window to the right"),
    Cmd((mod_c, "j"), cmd=lazy.layout.grow_down(), desc="Grow window down"),
    Cmd((mod_c, "k"), cmd=lazy.layout.grow_up(), desc="Grow window up"),
    # Cmd((mod, "n"), cmd=lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    # Cmd((mod_s, "Return"), cmd=lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),
    Cmd((mod_s, "Return"), cmd=lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),
    Cmd((mod, "Return"), cmd=cmd(terminal), desc="Launch terminal"),
    Cmd((mod, "d"), cmd=cmd(["rofi", "-show", "drun"]), desc="Launch launcher"),
    # Toggle between different layouts as defined below
    Cmd((mod, "Tab"), cmd=lazy.next_layout(), desc="Toggle between layouts"),
    Cmd((mod_s, "q"), cmd=lazy.window.kill(), desc="Kill focused window"),
    Cmd((mod, "f"), cmd=lazy.window.toggle_fullscreen(), desc="Toggle fullscreen on the focused window"),
    Cmd((mod_s, "space"), cmd=lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Cmd((mod_s, "r"), cmd=lazy.reload_config(), desc="Reload the config"),
    Cmd((mod_c, "q"), cmd=lazy.shutdown(), desc="Shutdown Qtile"),
    Cmd(
        (mod, "asciicircum"),
        cmd=lazy.group["dropdown"].dropdown_toggle("dropdown"),
        desc="Spawn a command using a prompt widget",
    ),
]

groups = [Group(i) for i in "123456789"]

for i in groups:
    cmds.extend(
        [
            # mod + group number = switch to group
            Cmd(
                (mod, i.name),
                cmd=lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Cmd(
                (mod_s, i.name),
                cmd=lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key(mod_s, i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

keys = [key for cmd in cmds for key in cmd.to_keys()]

layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font="Fira Code Nerd Font",
    fontsize=14,
    padding=3,
)
extension_defaults = widget_defaults.copy()

bar = bar.Bar(
    [
        widget.Chord(
            chords_colors={
                "A": ("2980b9", "ffffff"),
                "launch": ("#ff0000", "#ffffff"),
            },
            name_transform=lambda name: name.upper(),
        ),
        widget.Battery(charge_char="󰂄", format="{percent:2.0%}", update_interval=1),
        widget.CheckUpdates(),
        widget.GroupBox(),
        widget.Memory(),
        widget.PulseVolume(),
        widget.Volume(),
        widget.Prompt(),
        # NB Systray is incompatible with Wayland, consider using StatusNotifier instead
        widget.Spacer(),
        widget.ThermalSensor(update_interval=1),
        widget.Clock(format="%a %d.%m.%Y", foreground="#F92782"),
        widget.Clock(format="%H:%M", foreground="#DEED12"),
        widget.Systray(),
    ],
    32,
    margin=[5, 5, 5, 5],
    opacity=0,
    background="#222222",
)

screens = [
    Screen(bottom=bar, x11_drag_polling_rate=60, wallpaper=str(wallpaper), wallpaper_mode="stretch"),
]

# Drag floating layouts.
mouse = [
    Drag(mod, "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag(mod, "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click(mod, "Button1", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
