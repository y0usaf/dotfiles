import fabric
import os
import psutil
import subprocess
import json
from loguru import logger
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.system_tray import SystemTray
from fabric.widgets.wayland import Window
from fabric.widgets.overlay import Overlay
from fabric.widgets.eventbox import EventBox
from fabric.widgets.date_time import DateTime
from fabric.widgets.centerbox import CenterBox
from fabric.utils.string_formatter import FormattedString
from fabric.widgets.circular_progress_bar import CircularProgressBar
from fabric.hyprland.widgets import WorkspaceButton, Workspaces, Language
from fabric.utils.helpers import (
    set_stylesheet_from_file,
    bulk_replace,
    monitor_file,
    invoke_repeater,
    get_relative_path,
)


def get_monitor_ids():
    try:
        result = subprocess.check_output(["hyprctl", "monitors", "-j"])
        monitors = json.loads(result)
        return [monitor["id"] for monitor in monitors]
    except Exception as e:
        print(f"Error retrieving monitor IDs: {e}")
        return []


PYWAL = False
AUDIO_WIDGET = True

if AUDIO_WIDGET is True:
    try:
        from fabric.audio.service import Audio
    except Exception as e:
        logger.error(e)
        AUDIO_WIDGET = False


class StatusBar(Window):
    def __init__(self, layer, anchor, monitor):
        super().__init__(
            layer=layer,
            anchor=anchor,
            margin="2px 20px 2px 20px" if layer == "top" else "2px 20px 2px 20px",
            exclusive=True,
            visible=True,
            monitor=monitor,
        )
        self.center_box = CenterBox(name="main-window")
        self.workspaces = Workspaces(
            spacing=2,
            name="workspaces",
            buttons_list=[
                WorkspaceButton(label=FormattedString("1")),
                WorkspaceButton(label=FormattedString("2")),
                WorkspaceButton(label=FormattedString("3")),
                WorkspaceButton(label=FormattedString("4")),
                WorkspaceButton(label=FormattedString("5")),
                WorkspaceButton(label=FormattedString("6")),
                WorkspaceButton(label=FormattedString("7")),
            ],
        )
        self.language = Language(
            formatter=FormattedString(
                "{en_US.UTF-8}",
                replace_lang=lambda x: bulk_replace(
                    x,
                    [r".*Eng.*", r".*Ar.*"],
                    ["ENG", "ARA"],
                    regex=True,
                ),
            ),
            name="hyprland-window",
        )
        self.date_time = DateTime(name="date-time")
        self.system_tray = SystemTray(name="system-tray")
        self.ram_circular_progress_bar = CircularProgressBar(
            name="ram-circular-progress-bar",
            background_color=False,
            radius_color=False,
            pie=True,
        )
        self.cpu_circular_progress_bar = CircularProgressBar(
            name="cpu-circular-progress-bar",
            background_color=False,
            radius_color=False,
            pie=True,
        )
        self.circular_progress_bars_overlay = Overlay(
            children=self.ram_circular_progress_bar,
            overlays=[
                self.cpu_circular_progress_bar,
                Label("", style="margin: 0px 6px 0px 0px; font-size: 12px"),
            ],
        )
        self.volume = VolumeWidget() if AUDIO_WIDGET is True else None
        self.widgets_container = Box(
            spacing=2,
            orientation="h",
            name="widgets-container",
            children=[
                self.circular_progress_bars_overlay,
            ],
        )
        self.widgets_container.add(self.volume) if self.volume is not None else None

        self.center_box.add_center(self.system_tray)
        self.center_box.add_center(self.workspaces)
        self.center_box.add_center(self.date_time)
        self.add(self.center_box)

        invoke_repeater(1000, self.update_progress_bars)
        self.update_progress_bars()  # initial call

        self.show_all()

    def update_progress_bars(self):
        self.ram_circular_progress_bar.percentage = psutil.virtual_memory().percent
        self.cpu_circular_progress_bar.percentage = psutil.cpu_percent()
        return True


def apply_style(*args):
    logger.info("[Bar] CSS applied")
    return set_stylesheet_from_file(get_relative_path("bar.css"))


if __name__ == "__main__":
    monitor_ids = get_monitor_ids()
    print(monitor_ids)
    for display in monitor_ids:
        top_bar = StatusBar(layer="top", anchor="center top center", monitor=display)
        bottom_bar = StatusBar(
            layer="bottom", anchor="center bottom center", monitor=display
        )

    if PYWAL is True:
        monitor = monitor_file(
            f"/home/{os.getlogin()}/.cache/wal/colors-widgets.css", "none"
        )
        monitor.connect("changed", apply_style)

    # initialize style
    apply_style()
    fabric.start()
