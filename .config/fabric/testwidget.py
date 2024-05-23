import fabric
from fabric.widgets.wayland import Window
from fabric.widgets.button import Button
from fabric.widgets.box import Box
from fabric.hyprland.widgets import Workspaces, WorkspaceButton
from fabric.utils import set_stylesheet_from_file, get_relative_path


class OverviewWidget(Window):
    def __init__(self):
        super().__init__(
            layer="bottom",
            anchor="center",
            margin="10px 10px 10px 10px",
            exclusive=True,
        )
        self.workspaces_button = Button(label="Workspaces")
        self.workspaces_button.connect("clicked", self.on_workspaces_clicked)

        self.box = Box(orientation="vertical", spacing=10)
        self.box.add(self.workspaces_button)
        self.add(self.box)

    def on_workspaces_clicked(self, button):
        fabric.show_widget("MyWorkspaceWidget")
        self.close()


class MyWorkspaceWidget(Window):
    def __init__(self):
        super().__init__(
            layer="bottom",
            anchor="center",
            margin="10px 10px 10px 10px",
            exclusive=True,
        )
        self.workspaces = Workspaces()
        self.add(self.workspaces)


if __name__ == "__main__":
    widget = OverviewWidget()
    widget.show()
    fabric.start()
