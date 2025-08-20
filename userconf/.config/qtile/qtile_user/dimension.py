from __future__ import annotations

from contextlib import contextmanager
from dataclasses import dataclass
from typing import Literal

from libqtile.backend.base.window import Window
from libqtile.config import Screen
from libqtile.core.manager import Qtile
from libqtile.lazy import lazy

from qtile_user.sticky import current_window, get_qtile


class Dimension:
    def __init__(
        self,
        x: int,
        y: int,
        width: int,
        height: int,
        *,
        border: int = 0,
        min_width: int = 0,
        min_height: int = 0,
    ):
        self._x = x
        self._y = y
        self._width = width
        self._height = height
        self._border = border
        self._min_width = min_width
        self._min_height = min_height

    def stick_mode(
        self, screen: Dimension, delta: float = 0.05
    ) -> tuple[Literal["left", "right"] | None, Literal["top", "bottom"] | None]:
        width_delta = screen.inner_width * delta
        height_delta = screen.inner_height * delta
        if self.left - screen.left < width_delta:
            x_stick = "left"
        elif screen.right - self.right < width_delta:
            x_stick = "right"
        else:
            x_stick = None
        if self.top - screen.top < height_delta:
            y_stick = "top"
        elif screen.bottom - self.bottom < height_delta:
            y_stick = "bottom"
        else:
            y_stick = None
        return x_stick, y_stick

    def screen_fix(
        self,
        screen: Dimension,
        *,
        no_offscreen: bool,
        stick_mode: tuple[Literal["left", "right"] | None, Literal["top", "bottom"] | None] | None = None,
    ):
        if no_offscreen:
            self.right = min(self.right, screen.right)
            self.left = max(self.left, screen.left)
            self.bottom = min(self.bottom, screen.bottom)
            self.top = max(self.top, screen.top)
        if stick_mode is not None:
            x_mode, y_mode = stick_mode
            match x_mode:
                case None:
                    pass
                case "left":
                    self.left = min(self.left, screen.left)
                case "right":
                    self.right = max(self.right, screen.right)
            match y_mode:
                case None:
                    pass
                case "top":
                    self.top = min(self.top, screen.top)
                case "bottom":
                    self.bottom = max(self.bottom, screen.bottom)

    @property
    def x(self):
        return self._x

    @property
    def y(self):
        return self._y

    @property
    def inner_width(self):
        return self._width

    @property
    def outer_width(self):
        return self._width + 2 * self._border

    @property
    def inner_height(self):
        return self._height

    @property
    def outer_height(self):
        return self._height + 2 * self._border

    @property
    def left(self):
        return self._x

    @property
    def top(self):
        return self._y

    @property
    def right(self):
        return self._x + self._width + 2 * self._border

    @property
    def bottom(self):
        return self._y + self._height + 2 * self._border

    @x.setter
    def x(self, value: int):
        self._x = value

    @y.setter
    def y(self, value: int):
        self._y = value

    @inner_width.setter
    def inner_width(self, value: int):
        self._width = max(value, self._min_width)

    @outer_width.setter
    def outer_width(self, value: int):
        self.inner_width = value - 2 * self._border

    @inner_height.setter
    def inner_height(self, value: int):
        self._height = max(value, self._min_height)

    @outer_height.setter
    def outer_height(self, value: int):
        self.inner_height = value - 2 * self._border

    @left.setter
    def left(self, value: int):
        self._x = value

    @top.setter
    def top(self, value: int):
        self._y = value

    @right.setter
    def right(self, value: int):
        self._x += value - self._x - self._width - 2 * self._border

    @bottom.setter
    def bottom(self, value: int):
        self._y += value - self._y - self._height - 2 * self._border


@dataclass
class State:
    window: int
    screen: int


@dataclass
class Absolute:
    value: int
    mode: Literal["delta", "fixed"] = "delta"

    def modify(self, state: State) -> int:
        match self.mode:
            case "delta":
                return state.window + self.value
            case "fixed":
                return self.value


@dataclass
class Relative:
    value: float
    mode: Literal["delta", "fixed"] = "delta"

    def modify(self, state: State) -> int:
        update = round(self.value * state.screen)
        match self.mode:
            case "delta":
                return state.window + update
            case "fixed":
                return update


@contextmanager
def prevent_mouse_follow(qtile_obj: Qtile | None = None):
    qtile_obj = get_qtile() if qtile_obj is None else qtile_obj
    qtile_obj.config.follow_mouse_focus = False
    try:
        yield
    finally:

        def reset_focus():
            qtile_obj.config.follow_mouse_focus = True

        qtile_obj.call_later(0, reset_focus)


@lazy.function
def move_floating(qtile: Qtile, x: int, y: int, delta: float = 0.9):
    if (window := current_window(qtile)) is not None:
        with prevent_mouse_follow(qtile):
            screen = qtile.current_screen
            window_dim = Dimension(window.x + x, window.y + y, window.width, window.height, border=window.borderwidth)
            width_delta = round(window_dim.outer_width * delta)
            height_delta = round(window_dim.outer_height * delta)
            screen_dim = Dimension(
                screen.x - width_delta,
                screen.y - height_delta,
                screen.width + 2 * width_delta,
                screen.height + 2 * height_delta,
            )
            window_dim.screen_fix(screen_dim, no_offscreen=True)
            window.set_position_floating(window_dim.x, window_dim.y)


def place(
    window: Window,
    screen: Screen,
    width: Absolute | Relative,
    height: Absolute | Relative,
    x: Absolute | Relative | Literal["auto"] = "auto",
    y: Absolute | Relative | Literal["auto"] = "auto",
    *,
    min_width: int = 400,
    min_height: int = 225,
    no_offscreen: bool = True,
    sticky_delta: float | None = 0.025,
):
    with prevent_mouse_follow():
        window.enable_floating()
        screen_dim = Dimension(screen.dx, screen.dy, screen.dwidth, screen.dheight)
        window_dim = Dimension(
            window.x,
            window.y,
            window.width,
            window.height,
            border=window.borderwidth,
            min_width=min_width,
            min_height=min_height,
        )
        stick_mode = (None, None)
        if sticky_delta is not None:
            stick_mode = window_dim.stick_mode(screen_dim, sticky_delta)
        window_dim.outer_width = width.modify(State(window_dim.outer_width, screen.dwidth))
        window_dim.outer_height = height.modify(State(window_dim.outer_height, screen.dheight))
        if x == "auto":
            x = Absolute((window.width - window_dim.inner_width) // 2)
        if y == "auto":
            y = Absolute((window.height - window_dim.inner_height) // 2)
        window_dim.x = x.modify(State(window.x, screen.dwidth))
        window_dim.y = y.modify(State(window.y, screen.dheight))
        if sticky_delta is not None:
            x_stick_mode_prev, y_stick_mode_prev = stick_mode
            x_stick_mode, y_stick_mode = window_dim.stick_mode(screen_dim, sticky_delta)
            stick_mode = (x_stick_mode or x_stick_mode_prev, y_stick_mode or y_stick_mode_prev)
        window_dim.screen_fix(screen_dim, no_offscreen=no_offscreen, stick_mode=stick_mode)
        window.set_position_floating(window_dim.x, window_dim.y)
        window.set_size_floating(window_dim.inner_width, window_dim.inner_height)
