def remove_null_lines(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if "NULL" not in line:
                outfile.write(line)

def main():
    input_file = './Conversion_Table.csv'  # Replace with your input file path
    output_file = './Conversion_Table_New.csv'  # Replace with your output file path

    remove_null_lines(input_file, output_file)
    print("File processed successfully, NULL lines removed.")

if __name__ == "__main__":
    main()
