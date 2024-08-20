import fabric
import os
from loguru import logger
from fabric.widgets.box import Box
from fabric.widgets.wayland import Window
from fabric.widgets.date_time import DateTime
from fabric.utils import (
    set_stylesheet_from_file,
    monitor_file,
    get_relative_path,
)
from pynput import keyboard

PYWAL = False


class ClockWidget(Window):
    def __init__(self, **kwargs):
        super().__init__(
            layer="overlay",
            anchor="left top right",
            margin="240px 0px 0px 0px",
            children=Box(
                children=[
                    DateTime(format_list=["%A. %d %B"], name="date", interval=10000),
                    DateTime(format_list=["%I:%M"], name="clock"),
                ],
                orientation="v",
            ),
            all_visible=True,
            exclusive=False,
        )
        self.hide()  # Start with the widget hidden
        logger.info("ClockWidget initialized and hidden")


def apply_style(*args):
    logger.info("[Desktop Widget] CSS applied")
    return set_stylesheet_from_file(get_relative_path("desktop_widget.css"))


def on_press(key):
    logger.info(f"Key pressed: {key}")
    if key == keyboard.Key.tab:
        logger.info("Tab pressed, showing widget")
        desktop_widget.show()


def on_release(key):
    logger.info(f"Key released: {key}")
    if key == keyboard.Key.tab:
        logger.info("Tab released, hiding widget")
        desktop_widget.hide()


if __name__ == "__main__":
    logger.info("Starting desktop widget script")
    desktop_widget = ClockWidget()

    if PYWAL is True:
        monitor = monitor_file(
            f"/home/{os.getlogin()}/.cache/wal/colors-widgets.css", "none"
        )
        monitor.connect("changed", apply_style)

    # initialize style
    apply_style()

    # Set up keyboard listener
    logger.info("Setting up keyboard listener")
    listener = keyboard.Listener(on_press=on_press, on_release=on_release)
    listener.start()

    logger.info("Starting fabric")
    fabric.start()
