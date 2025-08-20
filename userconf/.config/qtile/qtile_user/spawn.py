from __future__ import annotations

from libqtile.lazy import LazyCall, lazy


def cmd(cmd: str | list[str]) -> LazyCall:
    return lazy.spawn(cmd)


def sh(cmd: str | list[str]) -> LazyCall:
    return lazy.spawn(cmd, shell=True)
