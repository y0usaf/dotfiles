from fabric import Application
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.datetime import DateTime
from fabric.utils import get_relative_path, invoke_repeater
from fabric.hyprland.service import Hyprland
from gi.repository import Gdk
import json
import os
import psutil
import subprocess


class SystemStats(Box):
    def __init__(self, **kwargs):
        super().__init__(orientation="h", spacing=20, **kwargs)

        self.ram_label = Label(name="ram-stat")
        self.cpu_temp_label = Label(name="cpu-temp")
        self.gpu_temp_label = Label(name="gpu-temp")
        self.clock = DateTime(name="clock", formatters=["%H:%M:%S"], interval=1000)

        self.add(self.ram_label)
        self.add(self.cpu_temp_label)
        self.add(self.gpu_temp_label)
        self.add(self.clock)

        invoke_repeater(1000, self.update_stats)

    def update_stats(self):
        ram = psutil.virtual_memory().used / (1024 * 1024)
        self.ram_label.set_label(f"RAM: {ram:.0f}MB")
        self.cpu_temp_label.set_label(f"CPU: {self.get_cpu_temp()}")
        self.gpu_temp_label.set_label(f"GPU: {self.get_gpu_temp()}°C")
        return True

    def get_gpu_temp(self):
        try:
            result = subprocess.run(
                ["nvidia-smi", "--query-gpu=temperature.gpu", "--format=csv,noheader"],
                capture_output=True,
                text=True,
            )
            return result.stdout.strip()
        except:
            return "N/A"

    def get_cpu_temp(self):
        try:
            result = subprocess.run(["sensors"], capture_output=True, text=True)
            for line in result.stdout.split("\n"):
                if "Tctl" in line:
                    return line.split()[1]
            return "N/A"
        except:
            return "N/A"


class MonitorWorkspaces(Box):
    def __init__(self, monitor_id: int, show_stats: bool = False, **kwargs):
        super().__init__(**kwargs)
        self.monitor_id = monitor_id
        self.show_stats = show_stats
        self.connection = Hyprland()
        self._active_workspace = None
        self._workspace_labels = {}

        # Create containers
        self.workspaces_box = Box(name="workspaces", spacing=0, orientation="h")
        self.add(self.workspaces_box)

        if show_stats:
            self.stats = SystemStats(name="system-stats")
            self.add(self.stats)

        # Connect to Hyprland events
        self.connection.connect("event::workspace", self.on_workspace)
        self.connection.connect("event::focusedmon", self.on_monitor_focus)
        self.connection.connect("event::createworkspace", self.update_workspaces)
        self.connection.connect("event::destroyworkspace", self.update_workspaces)

        if self.connection.ready:
            self.update_workspaces(None, None)
        else:
            self.connection.connect("event::ready", self.update_workspaces)

    def update_workspaces(self, _, __):
        """Update the workspace display"""
        # Clear existing labels
        for label in self._workspace_labels.values():
            self.workspaces_box.remove(label)
        self._workspace_labels.clear()

        # Get workspaces for this monitor
        workspaces_data = json.loads(os.popen("hyprctl workspaces -j").read())
        monitor_workspaces = [
            ws for ws in workspaces_data if ws.get("monitor") == f"DP-{self.monitor_id}"
        ]

        # Create labels for each workspace
        for workspace in monitor_workspaces:
            workspace_id = workspace["id"]
            label = Label(
                name="workspace",
                text=str(workspace_id),
                style_class=[
                    "workspace",
                    "active" if workspace_id == self._active_workspace else "",
                ],
            )
            self._workspace_labels[workspace_id] = label
            self.workspaces_box.add(label)

    def on_workspace(self, _, event):
        """Handle workspace change events"""
        if len(event.data) < 1:
            return

        workspace_id = int(event.data[0])

        # Update active workspace
        if self._active_workspace is not None:
            old_label = self._workspace_labels.get(self._active_workspace)
            if old_label:
                old_label.style_class = ["workspace"]

        self._active_workspace = workspace_id
        new_label = self._workspace_labels.get(workspace_id)
        if new_label:
            new_label.style_class = ["workspace", "active"]

    def on_monitor_focus(self, _, event):
        """Handle monitor focus events"""
        if len(event.data) < 2:
            return

        monitor_name, workspace_id = event.data
        if f"DP-{self.monitor_id}" != monitor_name:
            return

        self._active_workspace = int(workspace_id)
        self.update_workspaces(None, None)


def create_windows(show_stats=False):
    windows = []
    display = Gdk.Display.get_default()
    n_monitors = display.get_n_monitors()

    for monitor in range(n_monitors):
        top_window = Window(
            layer="overlay",
            anchor="top",
            margin="2px 0 0 0",
            exclusivity="none",
            monitor=monitor,
            child=MonitorWorkspaces(
                monitor_id=monitor,
                show_stats=show_stats,
                spacing=20,
                orientation="h",
            ),
            all_visible=True,
        )

        bottom_window = Window(
            layer="overlay",
            anchor="bottom",
            margin="0 0 2px 0",
            exclusivity="none",
            monitor=monitor,
            child=MonitorWorkspaces(
                monitor_id=monitor,
                show_stats=show_stats,
                spacing=20,
                orientation="h",
            ),
            all_visible=True,
        )

        windows.extend([top_window, bottom_window])

    return windows


if __name__ == "__main__":
    import sys

    show_stats = "--show-stats" in sys.argv

    app = Application("system-workspaces")

    for window in create_windows(show_stats):
        app.add_window(window)

    css_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "style.css")
    app.set_stylesheet_from_file(css_path)
    app.run()
