# generate_gif.py

from PIL import Image
import subprocess

# Configuration variables
IMAGE_PATH = "/home/y0usaf/DCIM/Twitch/RotatedBG.png"
GIF_PATH = "/home/y0usaf/DCIM/Twitch/output.gif"
MP4_PATH = "/home/y0usaf/DCIM/Twitch/output.mp4"

# Animation settings
MOVEMENT = (2, 2)  # Reduced to 2 pixels per frame
NUM_FRAMES = 125  # Increased to 125 to get similar total movement
FPS = 100  # Target 100 FPS
DURATION_PER_FRAME = int(1000 / FPS)  # Duration in milliseconds

# Resolution settings
TARGET_RESOLUTION = (3840, 2160)  # Width, Height

# Load the PNG image
input_image = Image.open(IMAGE_PATH)

# Create a list to store the frames
frames = []

# Generate the sequence of frames by moving the image diagonally
for i in range(NUM_FRAMES):
    # Copy the original image
    frame = input_image.copy()

    # Calculate the displacement for this frame
    displacement = (MOVEMENT[0] * (i + 1), MOVEMENT[1] * (i + 1))

    # Move the image diagonally
    frame = frame.transform(
        frame.size, Image.AFFINE, (1, 0, displacement[0], 0, 1, displacement[1])
    )

    # Append the frame to the list of frames
    frames.append(frame)

# Crop each frame to the target resolution from the center
cropped_frames = []
for frame in frames:
    # Calculate the coordinates for cropping
    width, height = frame.size
    left = (width - TARGET_RESOLUTION[0]) // 2
    top = (height - TARGET_RESOLUTION[1]) // 2
    right = left + TARGET_RESOLUTION[0]
    bottom = top + TARGET_RESOLUTION[1]

    # Crop the frame
    cropped_frame = frame.crop((left, top, right, bottom))
    cropped_frames.append(cropped_frame)

# Save GIF
cropped_frames[0].save(
    GIF_PATH,
    save_all=True,
    append_images=cropped_frames[1:],
    duration=DURATION_PER_FRAME,
    loop=0,
)

print(f"Generated GIF saved as: {GIF_PATH}")

# Convert to MP4 using ffmpeg
try:
    ffmpeg_cmd = [
        "ffmpeg",
        "-y",  # -y to overwrite output file
        "-i",
        GIF_PATH,
        "-movflags",
        "faststart",
        "-pix_fmt",
        "yuv420p",
        "-vf",
        "scale=trunc(iw/2)*2:trunc(ih/2)*2",  # Ensure dimensions are even
        MP4_PATH,
    ]
    subprocess.run(ffmpeg_cmd, check=True)
    print(f"Converted to MP4: {MP4_PATH}")
except subprocess.CalledProcessError as e:
    print(f"Error converting to MP4: {e}")
