from fabric import Application
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.hyprland.widgets import Workspaces, WorkspaceButton
from fabric.utils import get_relative_path
import json
from gi.repository import Gdk
import os


class MonitorWorkspaces(Workspaces):
    def __init__(self, monitor_id: int, **kwargs):
        self.monitor_id = monitor_id
        super().__init__(**kwargs)
        self.connection.connect("event::focusedmon", self.on_monitor_focus)
        self.connection.connect("event::moveworkspace", self.on_move_workspace)

    def on_ready(self, _):
        workspaces_data = json.loads(os.popen("hyprctl workspaces -j").read())

        # Only show workspaces for this monitor
        monitor_workspaces = [
            ws["id"] for ws in workspaces_data if ws.get("monitorID") == self.monitor_id
        ]

        # Get active workspace for this monitor
        monitors_data = json.loads(os.popen("hyprctl monitors -j").read())
        focused_monitor = next((m for m in monitors_data if m.get("focused")), None)

        if focused_monitor and focused_monitor.get("id") == self.monitor_id:
            self._active_workspace = focused_monitor.get("activeWorkspace", {}).get(
                "id"
            )
        else:
            self._active_workspace = None

        for workspace_id in monitor_workspaces:
            if not (btn := self.lookup_or_bake_button(workspace_id)):
                continue

            btn.empty = False
            if workspace_id == self._active_workspace:
                btn.active = True

            self.insert_button(btn)

    def on_createworkspace(self, _, event):
        if len(event.data) < 1:
            return

        # Get current workspace info to check which monitor it belongs to
        workspaces_data = json.loads(os.popen("hyprctl workspaces -j").read())

        workspace_id = int(event.data[0])
        workspace_info = next(
            (ws for ws in workspaces_data if ws["id"] == workspace_id), None
        )

        # Only show the workspace if it belongs to this monitor
        if workspace_info and workspace_info.get("monitorID") == self.monitor_id:
            if not (btn := self.lookup_or_bake_button(workspace_id)):
                return

            btn.empty = False
            if workspace_id == self._active_workspace:
                btn.active = True

            self.insert_button(btn)

    def on_monitor_focus(self, _, event):
        if len(event.data) < 2:
            return

        monitor_name, workspace_id = event.data
        monitors_data = json.loads(os.popen("hyprctl monitors -j").read())

        focused_monitor = next(
            (m for m in monitors_data if m.get("name") == monitor_name), None
        )

        if not focused_monitor:
            return

        if focused_monitor.get("id") == self.monitor_id:
            if self._active_workspace is not None and (
                old_btn := self._buttons.get(self._active_workspace)
            ):
                old_btn.active = False

            self._active_workspace = int(workspace_id)
            if btn := self._buttons.get(self._active_workspace):
                btn.active = True
        else:
            if self._active_workspace is not None and (
                old_btn := self._buttons.get(self._active_workspace)
            ):
                old_btn.active = False
            self._active_workspace = None

    def on_workspace(self, _, event):
        if len(event.data) < 1:
            return

        workspaces_data = json.loads(os.popen("hyprctl workspaces -j").read())

        workspace_id = int(event.data[0])
        workspace_info = next(
            (ws for ws in workspaces_data if ws["id"] == workspace_id), None
        )

        # Update active states based on monitor ownership
        if workspace_info and workspace_info.get("monitorID") == self.monitor_id:
            if self._active_workspace is not None and (
                old_btn := self._buttons.get(self._active_workspace)
            ):
                old_btn.active = False

            self._active_workspace = workspace_id
            if not (btn := self.lookup_or_bake_button(workspace_id)):
                return

            btn.urgent = False
            btn.active = True

            if btn not in self._container.children:
                self.insert_button(btn)
        else:
            # Remove the workspace button if it moved to another monitor
            if btn := self._buttons.get(workspace_id):
                self.remove_button(btn)

    def do_handle_button_press(self, button: WorkspaceButton):
        # When clicking a workspace button, move it to this monitor if it's on another monitor
        workspaces_data = json.loads(os.popen("hyprctl workspaces -j").read())

        workspace_info = next(
            (ws for ws in workspaces_data if ws["id"] == button.id), None
        )

        if workspace_info and workspace_info.get("monitorID") != self.monitor_id:
            # Move the workspace to this monitor first
            self.connection.send_command(
                f"dispatch moveworkspacetomonitor {button.id} {self.monitor_id}"
            )

        # Then switch to it
        self.connection.send_command(f"dispatch workspace {button.id}")
        return logger.info(f"[Workspaces] Moved to workspace {button.id}")

    def on_move_workspace(self, _, event):
        if len(event.data) < 2:
            return

        workspace_id = int(event.data[0])
        new_monitor_id = int(event.data[1])

        # If workspace moved to this monitor
        if new_monitor_id == self.monitor_id:
            if not (btn := self.lookup_or_bake_button(workspace_id)):
                return

            btn.empty = False
            if workspace_id == self._active_workspace:
                btn.active = True

            if btn not in self._container.children:
                self.insert_button(btn)

        # If workspace moved away from this monitor
        elif btn := self._buttons.get(workspace_id):
            if workspace_id == self._active_workspace:
                self._active_workspace = None
            self.remove_button(btn)


def create_windows():
    windows = []
    display = Gdk.Display.get_default()
    n_monitors = display.get_n_monitors()

    for monitor in range(n_monitors):
        # Create top window
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
                buttons_factory=lambda ws_id: WorkspaceButton(
                    id=ws_id, label=str(ws_id)
                ),
            ),
            all_visible=True,
        )

        # Create bottom window with similar configuration
        bottom_window = Window(
            layer="overlay",
            anchor="bottom",  # Changed to bottom
            margin="0 0 2px 0",  # Adjusted margin for bottom
            exclusivity="exclusive",
            monitor=monitor,
            child=MonitorWorkspaces(
                monitor_id=monitor,
                name="workspaces",
                spacing=0,
                buttons_factory=lambda ws_id: WorkspaceButton(
                    id=ws_id, label=str(ws_id)
                ),
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
