# generate_gif.py

from PIL import Image

# Define input image path
image_path = "/home/y0usaf/DCIM/Twitch/BG_5400x5400.png"
output_path = "/home/y0usaf/DCIM/Twitch/output.gif"
# Define movement parameters
movement = (5, 5)  # Pixels to move diagonally per frame

# Define number of frames
num_frames = 50 

# Define target resolution for cropping
target_resolution = (3840, 2160)  # Width, Height

# Define frames per second (fps)
fps = 60

# Load the PNG image
input_image = Image.open(image_path)

# Create a list to store the frames
frames = []

# Generate the sequence of frames by moving the image diagonally
for i in range(num_frames):
    # Copy the original image
    frame = input_image.copy()
    
    # Calculate the displacement for this frame
    displacement = (movement[0] * (i + 1), movement[1] * (i + 1))
    
    # Move the image diagonally
    frame = frame.transform(frame.size, Image.AFFINE, (1, 0, displacement[0], 0, 1, displacement[1]))
    
    # Append the frame to the list of frames
    frames.append(frame)

# Crop each frame to the target resolution from the center
cropped_frames = []
for frame in frames:
    # Calculate the coordinates for cropping
    width, height = frame.size
    left = (width - target_resolution[0]) // 2
    top = (height - target_resolution[1]) // 2
    right = left + target_resolution[0]
    bottom = top + target_resolution[1]
    
    # Crop the frame
    cropped_frame = frame.crop((left, top, right, bottom))
    cropped_frames.append(cropped_frame)

# Calculate the duration per frame based on the desired fps
duration_per_frame = int(1000 / fps)  # Duration in milliseconds

# Save the sequence of frames as a GIF with the specified duration
cropped_frames[0].save(output_path, save_all=True, append_images=cropped_frames[1:], duration=duration_per_frame, loop=0)

print(f"Generated GIF saved as: {output_path}")

