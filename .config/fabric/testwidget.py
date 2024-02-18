import fabric
from fabric.widgets.wayland import Window
from fabric.hyprland.widgets import Workspaces, WorkspaceButton
from fabric.widgets.label import Label
from fabric.utils import set_stylesheet_from_file, get_relative_path

class MyWorkspaceWidget(Window):
    def __init__(self):
        super().__init__(
            layer="bottom",
            anchor="center",
            margin="10px 10px 10px 10px",
            exclusive=True,
        )
        self.current_workspace_label = Label(
            label="Workspace Name Here"  # Dynamically update this label with the current workspace name
        )
        self.add(self.current_workspace_label)

if __name__ == "__main__":
    widget = MyWorkspaceWidget()
    # set_stylesheet_from_file(get_relative_path("your_stylesheet.css"))  # Optional: Apply CSS
    fabric.start()