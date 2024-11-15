from typing import cast
from fabric import Application
from fabric.widgets.wayland import WaylandWindow
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.image import Image
from fabric.widgets.button import Button
from fabric.widgets.eventbox import EventBox
from fabric.notifications import Notifications, Notification
from fabric.utils import get_relative_path, invoke_repeater
from gi.repository import GdkPixbuf, Gdk

NOTIFICATION_WIDTH = 360
NOTIFICATION_IMAGE_SIZE = 48
NOTIFICATION_TIMEOUT = 5 * 1000


class NotificationWidget(Box):
    def __init__(self, notification: Notification, **kwargs):
        super().__init__(
            size=(NOTIFICATION_WIDTH, -1),
            name="notification",
            spacing=8,
            orientation="v",
            **kwargs,
        )

        self._notification = notification

        # Create an EventBox to handle clicks
        event_box = EventBox(
            events=Gdk.EventMask.BUTTON_PRESS_MASK,
        )

        body_container = Box(spacing=4, orientation="h")

        if image_pixbuf := self._notification.image_pixbuf:
            body_container.add(
                Image(
                    pixbuf=image_pixbuf.scale_simple(
                        NOTIFICATION_IMAGE_SIZE,
                        NOTIFICATION_IMAGE_SIZE,
                        GdkPixbuf.InterpType.BILINEAR,
                    )
                )
            )

        text_container = Box(
            spacing=4,
            orientation="v",
            children=[
                Box(
                    orientation="h",
                    children=[
                        Label(
                            label=self._notification.summary,
                            ellipsization="middle",
                        )
                        .build()
                        .add_style_class("summary")
                        .unwrap(),
                    ],
                    h_expand=True,
                    v_expand=True,
                ).build(
                    lambda box, _: box.pack_end(
                        Button(
                            image=Image(
                                icon_name="close-symbolic",
                                icon_size=18,
                            ),
                            v_align="center",
                            h_align="end",
                            on_clicked=lambda *_: self._notification.close(),
                        ),
                        False,
                        False,
                        0,
                    )
                ),
                Label(
                    label=self._notification.body,
                    line_wrap="word-char",
                    v_align="start",
                    h_align="start",
                )
                .build()
                .add_style_class("body")
                .unwrap(),
            ],
            h_expand=True,
            v_expand=True,
        )

        body_container.add(text_container)
        event_box.add(body_container)
        self.add(event_box)

        # Connect click handler
        event_box.connect("button-press-event", self._on_click)

        notification.connect(
            "closed",
            lambda *_: (
                parent.remove(self) if (parent := self.get_parent()) else None,
                self.destroy(),
            ),
        )

        invoke_repeater(
            NOTIFICATION_TIMEOUT,
            lambda: notification.close("expired"),
            initial_call=False,
        )

    def _on_click(self, widget, event):
        """Handle click events on the notification"""
        if event.button == 1:  # Left click
            # If there are actions, invoke the default action
            if self._notification.actions:
                # The default action is typically the first one with key "default"
                for action in self._notification.actions:
                    if action.key == "default":
                        action.invoke()
                        break
                else:  # If no default action found, use the first action
                    self._notification.actions[0].invoke()

            # Emit action-invoked signal
            self._notification.action_invoked("default")

            # Close the notification after handling the action
            self._notification.close("dismissed")
            return True
        return False


if __name__ == "__main__":
    app = Application(
        "notifications",
        WaylandWindow(
            margin="8px 8px 8px 8px",
            anchor="top right",
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

    app.set_stylesheet_from_file(get_relative_path("./style.css"))
    app.run()
