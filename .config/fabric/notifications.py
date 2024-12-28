from typing import cast

from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.image import Image
from fabric.widgets.button import Button
from fabric.widgets.wayland import WaylandWindow
from fabric.notifications import Notifications, Notification
from fabric.utils import invoke_repeater, get_relative_path

from gi.repository import GdkPixbuf, GLib


NOTIFICATION_WIDTH = 360
NOTIFICATION_IMAGE_SIZE = 64
NOTIFICATION_TIMEOUT = 5 * 1000


class NotificationWidget(Box):
    def __init__(self, notification: Notification, **kwargs):
        super().__init__(
            size=(NOTIFICATION_WIDTH, -1),
            name="notification",
            spacing=12,
            orientation="v",
            margin=8,
            **kwargs,
        )

        self._notification = notification

        GLib.timeout_add(NOTIFICATION_TIMEOUT, self._on_timeout)

        body_container = Box(
            spacing=8,
            orientation="h",
            margin=4,
        )

        if image_pixbuf := self._notification.image_pixbuf:
            body_container.add(
                Image(
                    pixbuf=image_pixbuf.scale_simple(
                        NOTIFICATION_IMAGE_SIZE,
                        NOTIFICATION_IMAGE_SIZE,
                        GdkPixbuf.InterpType.BILINEAR,
                    ),
                    margin_end=8,
                )
            )

        text_container = Box(
            spacing=6,
            orientation="v",
            h_expand=True,
            v_expand=True,
        )

        header = Box(
            orientation="h",
            h_expand=True,
            margin_bottom=4,
        )

        summary_label = (
            Label(
                label=self._notification.summary,
                ellipsization="middle",
                h_align="start",
                h_expand=True,
            )
            .build()
            .add_style_class("summary")
            .unwrap()
        )

        close_button = Button(
            image=Image(
                icon_name="close-symbolic",
                icon_size=18,
            ),
            v_align="center",
            h_align="end",
            margin_start=8,
            on_clicked=lambda *_: self._notification.close(),
        )

        header.add(summary_label)
        header.add(close_button)
        text_container.add(header)

        text_container.add(
            Label(
                label=self._notification.body,
                line_wrap="word-char",
                v_align="start",
                h_align="start",
            )
            .build()
            .add_style_class("body")
            .unwrap()
        )

        body_container.add(text_container)
        self.add(body_container)

        if actions := self._notification.actions:
            self.add(
                Box(
                    spacing=4,
                    orientation="h",
                    children=[
                        Button(
                            h_expand=True,
                            v_expand=True,
                            label=action.label,
                            on_clicked=lambda *_, action=action: action.invoke(),
                        )
                        for action in actions
                    ],
                )
            )

        self._notification.connect(
            "closed",
            lambda *_: (
                parent.remove(self) if (parent := self.get_parent()) else None,
                self.destroy(),
            ),
        )

    def _on_timeout(self):
        """Handle the notification timeout by closing it."""
        self._notification.close()
        return False  # Don't repeat the timeout


if __name__ == "__main__":
    app = Application(
        "notifications",
        WaylandWindow(
            margin="8px 8px 8px 8px",
            anchor="top",  # Changed to "top" for center positioning
            child=Box(
                size=2,
                spacing=4,
                orientation="v",
            ).build(
                lambda viewport, _: Notifications(
                    on_notification_added=lambda notifs_service, nid: viewport.add(
                        NotificationWidget(
                            cast(
                                Notification,
                                notifs_service.get_notification_from_id(nid),
                            )
                        )
                    )
                )
            ),
            visible=True,
            all_visible=True,
        ),
    )

    app.hold()  # Keep the application running
    app.run()
