import csv

def read_csv(file_path):
    with open(file_path, mode='r', encoding='utf-8') as file:
        return list(csv.reader(file))

def write_csv(file_path, data):
    with open(file_path, mode='w', encoding='utf-8', newline='') as file:
        writer = csv.writer(file)
        writer.writerows(data)

def merge_tables(original_csv, new_csv):
    # Convert the lists to dictionaries for easier manipulation
    original_dict = {row[3]: row for row in original_csv}
    new_dict = {row[3]: row for row in new_csv}

    # Update or add new entries
    for key in new_dict:
        original_dict[key] = new_dict[key]

    # Convert the dictionary back to a list
    merged_data = list(original_dict.values())

    return merged_data

def main():
    original_csv_path = './Conversion_Table.csv'
    new_csv_path = './Conversion_Table_New.csv'

    original_csv = read_csv(original_csv_path)
    new_csv = read_csv(new_csv_path)

    # Skip the header row in new_csv
    merged_data = merge_tables(original_csv, new_csv[1:])

    write_csv(original_csv_path, merged_data)
    print("Conversion tables have been merged and updated successfully.")

if __name__ == "__main__":
    main()
