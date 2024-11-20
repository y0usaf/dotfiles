import os
import psutil
import subprocess
from datetime import datetime
from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.datetime import DateTime
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.utils import invoke_repeater, get_relative_path


class SystemMonitor(Window):
    def __init__(self):
        super().__init__(
            layer="overlay",
            anchor="top",
            margin="10px",
            exclusivity="exclusive",
            all_visible=True,
        )

        # Create widgets
        self.clock = DateTime(
            name="clock", formatters=["%H:%M:%S %d/%m"], interval=1000
        )

        self.ram_label = Label(name="ram")
        self.cpu_temp_label = Label(name="cpu-temp")
        self.gpu_temp_label = Label(name="gpu-temp")

        # Create main container
        self.container = Box(
            name="monitor-box",
            orientation="h",
            spacing=20,
            children=[
                self.clock,
                self.ram_label,
                self.cpu_temp_label,
                self.gpu_temp_label,
            ],
        )

        self.add(self.container)

        # Start update loop
        invoke_repeater(1000, self.update_stats)
        self.update_stats()

    def update_stats(self):
        # Update RAM usage
        ram_usage = psutil.virtual_memory().used / (1024 * 1024)  # Convert to MB
        self.ram_label.label = f"RAM: {ram_usage:.0f}MB"

        # Update CPU temperature
        try:
            cpu_temp = subprocess.check_output(
                "sensors | grep 'Tctl:' | awk '{print $2}'", shell=True, text=True
            ).strip()
            self.cpu_temp_label.label = f"CPU: {cpu_temp}"
        except:
            self.cpu_temp_label.label = "CPU: N/A"

        # Update GPU temperature
        try:
            gpu_temp = subprocess.check_output(
                "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader",
                shell=True,
                text=True,
            ).strip()
            self.gpu_temp_label.label = f"GPU: {gpu_temp}°C"
        except:
            self.gpu_temp_label.label = "GPU: N/A"

        return True


if __name__ == "__main__":
    app = Application("system-monitor")
    monitor = SystemMonitor()
    app.add_window(monitor)

    # Load CSS
    css_path = get_relative_path("style.css")
    app.set_stylesheet_from_file(css_path)

    app.run()
