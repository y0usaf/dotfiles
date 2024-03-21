
# path/filename: convert_json_to_strings_file.py

import json
from pathlib import Path

def convert_to_string(item):
    """
    Recursively converts all non-string items in a JSON-like structure to strings.
    Handles nested dictionaries and lists.
    """
    if isinstance(item, dict):
        return {k: convert_to_string(v) for k, v in item.items()}
    elif isinstance(item, list):
        return [convert_to_string(element) for element in item]
    elif not isinstance(item, str):
        return str(item)
    return item

def process_json_file(file_path, output_file_path=None):
    """
    Reads JSON data from a file, converts all non-string values to strings,
    and writes the modified data back to the original file or a new file.
    """
    # Ensure output_file_path is set; if not, overwrite the original file
    output_file_path = output_file_path or file_path
    
    # Read JSON data from file
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)

    # Convert data
    converted_data = convert_to_string(data)

    # Write the modified data to the output file
    with open(output_file_path, 'w', encoding='utf-8') as file:
        json.dump(converted_data, file, indent=4)

# Example usage
if __name__ == "__main__":
    file_path = Path('/home/7ktx/extractiondolphin.json')  # Path to the input JSON file
    output_file_path = Path('converted_input.json')  # Path to the output JSON file, optional
    
    process_json_file(file_path, output_file_path)