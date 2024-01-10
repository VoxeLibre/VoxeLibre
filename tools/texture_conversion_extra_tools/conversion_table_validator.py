import csv
import os

def validate_csv(file_path):
    with open(file_path, newline='') as csvfile:
        reader = csv.reader(csvfile, delimiter=',', quotechar='"')
        line_num = 1
        for row in reader:
            # Skip the header
            if line_num == 1:
                line_num += 1
                continue

            # Check if row has correct number of columns
            if len(row) != 10:
                print(f"Warning: Line {line_num} is not a valid CSV row.")
                line_num += 1
                continue

            # Validate source path
            if "/assets/minecraft/" not in row[0]:
                print(f"Warning: Line {line_num} does not contain '/assets/minecraft/' in the source path.")

            # Validate Source file and Target file
            if not row[1].endswith('.png'):
                print(f"Warning: Line {line_num} has an invalid or missing Source file. It should end with '.png'.")
            if not row[2].endswith('.png'):
                print(f"Warning: Line {line_num} has an invalid or missing Target file. It should end with '.png'.")

            line_num += 1

if __name__ == "__main__":
    csv_file = 'Conversion_Table.csv'
    if os.path.exists(csv_file):
        validate_csv(csv_file)
        print("Validated CSV, if no warnings or errors, your good!")
    else:
        print(f"Error: The file '{csv_file}' does not exist.")
