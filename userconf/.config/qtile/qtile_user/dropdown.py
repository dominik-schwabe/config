from __future__ import annotations

from libqtile.config import DropDown, Match, ScratchPad

DROPDOWN_TERMINAL_CMD = """
wezterm
    --config 'font_size=11.5' start
    --class ___dropdownterminal___
    -- bash -c '
        export IS_DROPDOWN=true;
        tmux -L dropdown attach -t dropdown &>/dev/null ||
        tmux -L dropdown new-session -t dropdown
    '
"""

MUSIC_PLAYER_CMD = """
wezterm start
    --class ___musicplayer___
    -- cmus
"""

IMAGE_VIEWER_CMD = r"""
sh -c "find ~/Pictures -maxdepth 1 -type f -printf '%T@ %p\n' | sort -nr | cut -d ' ' -f 2- | xargs -d '\n' nsxiv -N ___dropdown_images___"
"""


def centered(width: float, height: float) -> dict[str, float]:
    x = (1 - width) / 2
    y = (1 - height) / 2
    return {"width": width, "height": height, "x": x, "y": y}


DROPDOWN = ScratchPad(
    name="dropdown",
    dropdowns=[
        DropDown(
            name="dropdown-terminal",
            cmd=DROPDOWN_TERMINAL_CMD,
            match=Match(wm_class="___dropdownterminal___"),
            on_focus_lost_hide=False,
            opacity=1,
            **centered(0.85, 0.85),
        ),
        DropDown(
            name="music-player",
            cmd=MUSIC_PLAYER_CMD,
            match=Match(wm_class="___musicplayer___"),
            on_focus_lost_hide=False,
            opacity=1,
            **centered(0.85, 0.85),
        ),
        DropDown(
            name="image-viewer",
            cmd=IMAGE_VIEWER_CMD,
            match=Match(wm_class="___dropdown_images___"),
            on_focus_lost_hide=False,
            opacity=1,
            **centered(0.85, 0.85),
        ),
    ],
    single=True,
)
