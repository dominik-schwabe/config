from __future__ import annotations

from typing import Sequence

from libqtile.config import Key, KeyChord
from libqtile.lazy import LazyCall


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
        cmds: Sequence[Cmd | CmdChord],
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
