import json
import csv

# Load JSON data from file

json_file_path = r"D:\Upenn\25spring\MUSA-5090 Geospatial Cloud Computing & Visualization\GITHUB\Yixuan-assignment02\data\DECENNIALPL2020.P1_2025-03-10T181522\pl.json"

with open(json_file_path, "r") as json_file:
    data = json.load(json_file)

print("JSON file loaded successfully!")


# Extract headers and data rows
headers = data[0]  # First row contains headers
rows = data[1:]    # Remaining rows contain data

# Define CSV file name
csv_file = "census_data.csv"

# Write data to CSV
with open(csv_file, "w", newline="") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(headers)  # Write header row
    writer.writerows(rows)    # Write data rows

print(f"CSV file '{csv_file}' has been created successfully!")
