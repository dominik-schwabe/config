from __future__ import annotations

import asyncio
import re
import weakref
from asyncio import TaskGroup
from dataclasses import dataclass
from typing import Any, Literal

from libqtile import hook, layout
from libqtile.backend.base.window import Window
from libqtile.config import Click, Drag, Match, Screen
from libqtile.lazy import lazy

from qtile_user.bar import BAR
from qtile_user.config import MODKEY, WALLPAPER
from qtile_user.dimension import Relative, place
from qtile_user.dropdown import DROPDOWN
from qtile_user.keybindings import GROUPS, KEYS
from qtile_user.sticky import current_window, discard_sticky, get_qtile, make_sticky

groups = [*GROUPS, DROPDOWN]
keys = KEYS
layouts = [
    layout.MonadTall(single_border_width=0),
    layout.Max(),
]
widget_defaults = {"font": "Fira Code Nerd Font", "fontsize": 16, "padding": 3}
extension_defaults = widget_defaults.copy()
screens = [
    Screen(
        bottom=BAR,
        x11_drag_polling_rate=60,
        wallpaper=str(WALLPAPER),
        wallpaper_mode="stretch",
    )
]
mouse = [
    Drag([MODKEY], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([MODKEY], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([MODKEY], "Button1", lazy.window.bring_to_front()),
]

MPV_RE = re.compile("^mpv_media_stream.*$")

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = "floating_only"
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    border_focus="#e57373",
    border_normal="#424242",
    border_width=2,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(wm_class="Telegram"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
        Match(title=MPV_RE),
    ],
)
auto_fullscreen = True
focus_on_window_activation = "never"
reconfigure_screens = True
auto_minimize = False
wl_input_rules = None
# wl_input_rules = {
#     "type:keyboard": InputConfig(
#         kb_layout="de",
#         kb_variant="nodeadkeys",
#         kb_options="ctrl:nocaps",
#         kb_repeat_rate=33,
#         kb_repeat_delay=200,
#     ),
# }
wl_xcursor_theme = None
wl_xcursor_size = 24


async def spawn_exec(cmd: str, wait: float | int = 0):
    if wait > 0:
        await asyncio.sleep(wait)
    return await asyncio.create_subprocess_exec(cmd)


async def spawn_shell(cmd: str, wait: float | int = 0):
    if wait > 0:
        await asyncio.sleep(wait)
    return await asyncio.create_subprocess_shell(cmd)


@hook.subscribe.startup_once
async def autostart():
    async with TaskGroup() as tg:
        tg.create_task(spawn_exec("brave", 0))
        tg.create_task(spawn_exec("flameshot", 0))
        tg.create_task(spawn_shell("is_productive_system && Telegram -startintray", 0))
        tg.create_task(spawn_shell("is_productive_system && birdtray", 0))
        tg.create_task(spawn_exec("spotify-launcher", 0))
        # tg.create_task(spawn_shell("is_productive_system && is_work_time && discord --start-minimized", 0))


@hook.subscribe.client_focus
def client_mouse_enter_hook(client: Any):
    if client.floating:
        client.bring_to_front()


@hook.subscribe.client_new
def client_new(client: Window):
    if MPV_RE.match(client.name):
        client.can_steal_focus = False


@hook.subscribe.client_managed
def client_managed(window: Window):
    if MPV_RE.match(window.name):
        make_sticky(window)
        place(
            window,
            get_qtile().current_screen,
            x=Relative(1, "fixed"),
            y=Relative(0, "fixed"),
            width=Relative(0.3, "fixed"),
            height=Relative(0.3, "fixed"),
        )
    LAST_STATE[window] = WindowState.new(window)


def get_state(window: Window) -> Literal["full", "float", "normal"]:
    if window.fullscreen or window.maximized:
        return "full"
    if window.floating:
        return "float"
    return "normal"


def get_position(window: Window):
    if window.base_x is None or window.base_y is None or window.base_width is None or window.base_height is None:
        return None
    return window.base_x, window.base_y, window.base_width, window.base_height


@dataclass
class WindowState:
    current_state: Literal["full", "float", "normal"]
    prev_state: Literal["full", "float", "normal"]
    position: tuple[int, int, int, int] | None

    @classmethod
    def new(cls, window: Window):
        return cls(get_state(window), "normal", get_position(window))

    def update(self, window: Window):
        new_state = get_state(window)
        if new_state != self.current_state:
            if self.prev_state == "float" and self.current_state == "full" and self.position is not None:
                x, y, width, height = self.position
                window.set_position_floating(x, y)
                window.set_size_floating(width, height)
            self.prev_state = self.current_state
            self.current_state = get_state(window)
        self.position = get_position(window) if window.floating else None


LAST_STATE = weakref.WeakKeyDictionary[Window, WindowState]()


@hook.subscribe.float_change
def float_change():
    if (window := current_window()) is not None:
        if window.minimized:
            window.minimized = False
        if (last_state := LAST_STATE.get(window)) is not None:
            last_state.update(window)
        else:
            LAST_STATE[window] = WindowState.new(window)
        if not window.floating:
            discard_sticky(window)
