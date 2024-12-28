from fabric import Application
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.utils import get_relative_path
from fabric.hyprland.service import Hyprland
from gi.repository import Gdk
import json
import os


def get_hyprland_connection() -> Hyprland:
    global connection
    if not connection:
        connection = Hyprland()
    return connection


connection: Hyprland | None = None


class MonitorWorkspaces(Box):
    def __init__(self, monitor_id: int, **kwargs):
        super().__init__(**kwargs)
        self.monitor_id = monitor_id
        self.connection = get_hyprland_connection()
        self._active_workspace = None
        self._workspace_labels = {}

        # Connect to Hyprland events
        self.connection.connect("event::workspace", self.on_workspace)
        self.connection.connect("event::focusedmon", self.on_monitor_focus)
        self.connection.connect("event::createworkspace", self.update_workspaces)
        self.connection.connect("event::destroyworkspace", self.update_workspaces)

        # Initial setup
        if self.connection.ready:
            self.update_workspaces(None, None)
        else:
            self.connection.connect("event::ready", self.update_workspaces)

    def update_workspaces(self, _, __):
        """Update the workspace display"""
        # Clear existing labels
        for label in self._workspace_labels.values():
            self.remove(label)
        self._workspace_labels.clear()

        # Get workspaces for this monitor
        workspaces_data = json.loads(os.popen("hyprctl workspaces -j").read())
        monitor_workspaces = [
            ws["id"] for ws in workspaces_data if ws.get("monitorID") == self.monitor_id
        ]

        # Get active workspace
        monitors_data = json.loads(os.popen("hyprctl monitors -j").read())
        focused_monitor = next(
            (m for m in monitors_data if m.get("id") == self.monitor_id), None
        )
        self._active_workspace = (
            focused_monitor.get("activeWorkspace", {}).get("id")
            if focused_monitor
            else None
        )

        # Create labels for each workspace
        for ws_id in sorted(monitor_workspaces):
            label = Label(
                name="workspace-label",
                label=str(ws_id),
                style_classes=[
                    "workspace",
                    "active" if ws_id == self._active_workspace else "inactive",
                ],
            )
            self._workspace_labels[ws_id] = label
            self.add(label)

    def on_workspace(self, _, event):
        if len(event.data) < 1:
            return

        workspace_id = int(event.data[0])
        workspaces_data = json.loads(os.popen("hyprctl workspaces -j").read())
        workspace_info = next(
            (ws for ws in workspaces_data if ws["id"] == workspace_id), None
        )

        if workspace_info and workspace_info.get("monitorID") == self.monitor_id:
            self.update_workspaces(None, None)

    def on_monitor_focus(self, _, event):
        if len(event.data) < 2:
            return

        monitor_name, workspace_id = event.data
        monitors_data = json.loads(os.popen("hyprctl monitors -j").read())
        focused_monitor = next(
            (m for m in monitors_data if m.get("name") == monitor_name), None
        )

        if focused_monitor and focused_monitor.get("id") == self.monitor_id:
            self.update_workspaces(None, None)


def create_windows():
    windows = []
    display = Gdk.Display.get_default()
    n_monitors = display.get_n_monitors()

    for monitor in range(n_monitors):
        # Create top bar
        top_window = Window(
            layer="overlay",
            anchor="top",
            margin="2px 0 0 0",
            exclusivity="exclusive",
            monitor=monitor,
            child=MonitorWorkspaces(
                monitor_id=monitor,
                name="workspaces",
                spacing=0,
                orientation="h",
            ),
            all_visible=True,
        )

        # Create bottom bar
        bottom_window = Window(
            layer="overlay",
            anchor="bottom",
            margin="0 0 2px 0",
            exclusivity="exclusive",
            monitor=monitor,
            child=MonitorWorkspaces(
                monitor_id=monitor,
                name="workspaces",
                spacing=0,
                orientation="h",
            ),
            all_visible=True,
        )

        windows.extend([top_window, bottom_window])

    return windows


if __name__ == "__main__":
    app = Application("workspaces")

    for window in create_windows():
        app.add_window(window)

    css_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "style.css")
    app.set_stylesheet_from_file(css_path)
    app.run()
