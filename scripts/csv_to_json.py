import os
import sys
import pandas as pd
import json
import math

def csv_to_json(input_path, num_chunks=1):
    # If the input path is a directory, process all CSV files in the directory
    if os.path.isdir(input_path):
        for file in os.listdir(input_path):
            if file.endswith(".csv"):
                csv_file_path = os.path.join(input_path, file)
                json_file_path = os.path.splitext(csv_file_path)[0]
                
                df = pd.read_csv(csv_file_path)
                json_data = df.to_dict(orient='records')
                
                # Convert values to strings or None
                json_data = [{k: str(v) if not (isinstance(v, float) and math.isnan(v)) else None for k, v in record.items()} for record in json_data]
                
                # Split the JSON data into chunks
                chunk_size = len(json_data) // num_chunks
                for i in range(num_chunks):
                    start_index = i * chunk_size
                    end_index = (i + 1) * chunk_size if i < num_chunks - 1 else len(json_data)
                    chunk_data = json_data[start_index:end_index]
                    
                    chunk_file_path = f"{json_file_path}_{i+1}.json"
                    with open(chunk_file_path, 'w') as json_file:
                        json.dump(chunk_data, json_file, indent=2)
                    
                    print(f"Converted {csv_file_path} to {chunk_file_path}")
    
    # If the input path is a file, process the single CSV file
    elif os.path.isfile(input_path):
        if input_path.endswith(".csv"):
            json_file_path = os.path.splitext(input_path)[0]
            
            df = pd.read_csv(input_path)
            json_data = df.to_dict(orient='records')
            
            # Convert values to strings or None
            json_data = [{k: str(v) if not (isinstance(v, float) and math.isnan(v)) else None for k, v in record.items()} for record in json_data]
            
            # Split the JSON data into chunks
            chunk_size = len(json_data) // num_chunks
            for i in range(num_chunks):
                start_index = i * chunk_size
                end_index = (i + 1) * chunk_size if i < num_chunks - 1 else len(json_data)
                chunk_data = json_data[start_index:end_index]
                
                chunk_file_path = f"{json_file_path}_{i+1}.json"
                with open(chunk_file_path, 'w') as json_file:
                    json.dump(chunk_data, json_file, indent=2)
                
                print(f"Converted {input_path} to {chunk_file_path}")
        else:
            print("Input file is not a CSV file.")
    
    else:
        raise ValueError("Input path is not a valid file or directory")

# Usage
if len(sys.argv) < 2 or len(sys.argv) > 3:
    print("Usage: python csv_to_json.py <input_path> [num_chunks]")
    sys.exit(1)

input_path = sys.argv[1]
num_chunks = int(sys.argv[2]) if len(sys.argv) == 3 else 1

if os.path.exists(input_path):
    csv_to_json(input_path, num_chunks)
else:
    print("Input path does not exist.")