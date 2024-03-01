# path/rename_folders.py
import os

def apply_naming_convention(name):
    """
    Applies the naming convention to a single folder name:
    Capitalize the first letter and make subsequent letters lowercase until _,
    then repeat for each segment.
    """
    return '_'.join(part.capitalize() for part in name.split('_'))

def rename_folders_recursively(start_path):
    """
    Recursively traverses directories from start_path, renaming them
    to follow the naming convention.
    """
    for root, dirs, files in os.walk(start_path, topdown=False):
        for name in dirs:
            new_name = apply_naming_convention(name)
            if new_name != name:
                original_path = os.path.join(root, name)
                new_path = os.path.join(root, new_name)
                try:
                    os.rename(original_path, new_path)
                    print(f"Renamed '{original_path}' to '{new_path}'")
                except OSError as e:
                    print(f"Error renaming '{original_path}' to '{new_path}': {e}")

# Example usage
if __name__ == "__main__":
    start_directory = "/home/y0usaf/Music"  # Change to your start directory
    rename_folders_recursively(start_directory)
