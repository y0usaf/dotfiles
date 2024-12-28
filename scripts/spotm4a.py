#!/usr/bin/env python3
import sys
import os
import subprocess
from pathlib import Path
from typing import Dict, List
from mutagen.mp4 import MP4
from collections import defaultdict


def check_dependencies() -> None:
    """Verify spotdl is installed."""
    try:
        subprocess.run(["spotdl", "--version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print(
            "Error: spotdl is not installed. Install with: pip install spotdl",
            file=sys.stderr,
        )
        sys.exit(1)


def download_music(output_folder: str, spotify_link: str) -> bool:
    """Download music using spotdl."""
    try:
        result = subprocess.run(
            [
                "spotdl",
                "--format",
                "m4a",
                "--output",
                "{artist}_{title}",
                "--threads",
                "8",
                "--restrict",
                "--sponsor-block",
                "download",
                spotify_link,
            ],
            cwd=output_folder,
            check=True,
        )
        return True
    except subprocess.CalledProcessError:
        print("Error: Download failed", file=sys.stderr)
        return False


def sort_into_albums(folder_path: Path) -> None:
    """Sort songs into album folders if multiple songs from the same album exist."""
    # Group files by album
    album_files: Dict[str, List[Path]] = defaultdict(list)

    # Scan all m4a files and group by album
    for file_path in folder_path.glob("*.m4a"):
        try:
            audio = MP4(file_path)
            if "\xa9alb" in audio.tags:  # Album tag
                album_name = audio.tags["\xa9alb"][0]
                album_files[album_name].append(file_path)
        except Exception as e:
            print(
                f"Warning: Could not read metadata from {file_path}: {e}",
                file=sys.stderr,
            )
            continue

    # Move files into album folders if there are more than 2 songs from the same album
    for album_name, files in album_files.items():
        if len(files) > 2:
            # Create safe album folder name
            safe_album_name = "".join(
                c if c.isalnum() or c in (" ", "-") else "_" for c in album_name
            )
            album_dir = folder_path / safe_album_name
            album_dir.mkdir(exist_ok=True)

            # Move all files from this album to the album directory
            for file_path in files:
                try:
                    file_path.rename(album_dir / file_path.name)
                except Exception as e:
                    print(f"Warning: Could not move {file_path}: {e}", file=sys.stderr)


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} output_folder spotify_link", file=sys.stderr)
        print(
            f'Example: {sys.argv[0]} ~/Music "https://open.spotify.com/track/..."',
            file=sys.stderr,
        )
        sys.exit(1)

    output_folder = Path(sys.argv[1]).expanduser()
    spotify_link = sys.argv[2].split("?")[0]  # Remove any URL parameters

    # Validate Spotify link
    if not spotify_link.startswith("https://open.spotify.com/"):
        print("Error: Invalid Spotify link format", file=sys.stderr)
        print("Link should start with 'https://open.spotify.com/'", file=sys.stderr)
        sys.exit(1)

    # Create output directory
    try:
        output_folder.mkdir(parents=True, exist_ok=True)
    except Exception as e:
        print(f"Error: Failed to create output directory: {e}", file=sys.stderr)
        sys.exit(1)

    # Check dependencies
    check_dependencies()

    print("Starting download...")
    if download_music(str(output_folder), spotify_link):
        print("Download completed successfully!")
        print("Sorting files into album folders...")
        sort_into_albums(output_folder)
        print("Sorting completed!")
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
