from __future__ import annotations

from typing import Any

from libqtile.utils import send_notification


def notify(message: Any, *, title: str = "debug"):
    send_notification(title, str(message))


def urgent(message: Any, *, title: str = "debug"):
    send_notification(title, str(message), urgent=True)
