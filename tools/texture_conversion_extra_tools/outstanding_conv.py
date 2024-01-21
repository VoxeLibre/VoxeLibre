import csv

def read_missing_textures(file_path):
    with open(file_path, 'r') as file:
        return [line.strip().split('/')[-1] for line in file.readlines()]

def read_conversion_table(file_path):
    with open(file_path, 'r') as file:
        return list(csv.reader(file))

def find_outstanding_entries(missing_textures, conversion_table):
    outstanding_entries = []
    for row in conversion_table:
        if row[1] in missing_textures:
            outstanding_entries.append(row)
    return outstanding_entries

def write_outstanding_entries(file_path, outstanding_entries):
    with open(file_path, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerows(outstanding_entries)

def main():
    missing_textures_file = './missing_textures_filtered.txt'
    conversion_table_file = './Conversion_Table.csv'
    output_file = './Conversion_Table_Outstanding.csv'

    missing_textures = read_missing_textures(missing_textures_file)
    conversion_table = read_conversion_table(conversion_table_file)
    outstanding_entries = find_outstanding_entries(missing_textures, conversion_table)

    write_outstanding_entries(output_file, outstanding_entries)
    print("Outstanding conversion table entries written to:", output_file)

if __name__ == "__main__":
    main()