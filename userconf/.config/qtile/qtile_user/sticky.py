from __future__ import annotations

import typing
import weakref
from typing import Any

from libqtile import hook, qtile
from libqtile.backend.base.window import Window
from libqtile.core.manager import Qtile
from libqtile.lazy import lazy

from qtile_user.util import notify

STICKY_WINDOWS = weakref.WeakSet[Any]()


def get_qtile() -> Qtile:
    return typing.cast("Qtile", qtile)


def current_window(qtile_obj: Qtile | None = None) -> Window | None:
    qtile_obj = get_qtile() if qtile_obj is None else qtile_obj
    return typing.cast("Window | None", qtile_obj.current_screen.group.current_window)


def make_sticky(window: Window):
    window.enable_floating()
    STICKY_WINDOWS.add(window)


def discard_sticky(window: Window):
    STICKY_WINDOWS.discard(window)


@lazy.function
def toggle_sticky_windows(qtile: Qtile):
    if (window := current_window(qtile)) is not None:
        if window in STICKY_WINDOWS:
            discard_sticky(window)
        else:
            make_sticky(window)


@hook.subscribe.setgroup
def move_sticky_windows():
    for window in STICKY_WINDOWS:
        window.togroup()
