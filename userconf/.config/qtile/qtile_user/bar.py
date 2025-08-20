from __future__ import annotations

import subprocess
from pathlib import Path

from libqtile import bar, widget
from libqtile.widget import base

BIN_PATH = Path("~/.bin").expanduser()


def format_muted(mute_str: str) -> str:
    if mute_str == "true":
        return "<span foreground='#FF0000'></span>"
    else:
        return "<span foreground='#00FF00'></span>"


class MicrophoneMute(base.InLoopPollText):
    def poll(self):
        result = subprocess.run(BIN_PATH / "volume_info", capture_output=True, text=True)
        if result.returncode != 0:
            return f"<span foreground='#FF0000'>ERR {result.returncode}</span>"
        return " ".join([format_muted(e) for e in result.stdout.split()[2:]])


SEP_WIDGET = widget.TextBox(" ❰ ", foreground="#ED9D12")

BAR = bar.Bar(
    [
        widget.Chord(
            chords_colors={
                "A": ("#2980b9", "#FFFFFF"),
                "launch": ("#FF0000", "#FFFFFF"),
            },
            name_transform=str.upper,
        ),
        widget.GroupBox(
            this_current_screen_border="#6688dd",
            inactive="#888888",
            disable_drag=True,
            use_mouse_wheel=False,
            hide_unused=True,
            toggle=False,
        ),
        widget.Prompt(),
        widget.TaskList(
            foreground="#aaaaaa",
            max_title_width=256,
            markup_focused='<span foreground="#00DD00">{}</span>',
        ),
        # widget.Spacer(),
        widget.Memory(
            measure_mem="G",
            format="{MemPercent:2.0f}% ({MemTotal:.1f}{mm})",
            foreground="#00FFFF",
        ),
        SEP_WIDGET,
        widget.ThermalSensor(
            update_interval=1,
            fgcolor_normal="#FFFFFF",
            fgcolor_high="#FD971F",
            fgcolor_crit="#FF0000",
            high=65,
            crit=75,
            format="{temp:2.0f}°C",
            format_crit="{temp:2.0f}°C",
        ),
        SEP_WIDGET,
        widget.Battery(
            charge_char="󰜷",
            discharge_char="󰜮",
            full_char="",
            empty_char="",
            not_charging_char="-",
            format="{char} {percent:2.0%}",
            update_interval=1,
            low_percentage=0.2,
            low_foreground="#FFFFFF",
            low_background="#FF0000",
            foreground="#00FF00",
            show_short_text=False,
        ),
        SEP_WIDGET,
        widget.PulseVolume(
            foreground="#00FFFF",
            unmute_format="{volume:3d}%",
            limit_max_volume=True,
            mute_format=" 🔇 ",
        ),
        MicrophoneMute(update_interval=0.5),
        SEP_WIDGET,
        widget.Clock(format="%a %d.%m.%Y", foreground="#F92782"),
        widget.Clock(format="%H:%M", foreground="#DEED12"),
        # NB Systray is incompatible with Wayland, consider using StatusNotifier instead
        widget.Systray(),
    ],
    24,
    background="222222",
)
