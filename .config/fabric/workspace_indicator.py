from fabric import Application
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.hyprland.widgets import Workspaces
from fabric.utils import get_relative_path

if __name__ == "__main__":
    # Top workspace indicator
    top_window = Window(
        layer="overlay",
        anchor="top",
        margin="2px 0 0 0",
        exclusivity="exclusive",
        child=Workspaces(
            name="workspaces",
            spacing=0,
        ),
        all_visible=True,
    )

    # Bottom workspace indicator
    bottom_window = Window(
        layer="overlay",
        anchor="bottom",
        margin="0 0 2px 0",
        exclusivity="exclusive",
        child=Workspaces(
            name="workspaces",
            spacing=0,
        ),
        all_visible=True,
    )

    app = Application("workspace-indicator", [top_window, bottom_window])
    app.set_stylesheet_from_file(get_relative_path("style.css"))
    app.run()
