import csv

# Open the CSV file
with open('./Assets/EET Mod Install Order Guide - EET.csv', 'r') as file:
    # Create a CSV reader object
    csv_reader = csv.DictReader(file)

    # Find the maximum length of Mod Name and Install Before values
    max_mod_name_length = max(len(row['Mod Name']) for row in csv_reader)
    file.seek(0)  # Reset the file pointer to the beginning
    max_install_before_length = max(len(row['Install Before']) for row in csv_reader)
    file.seek(0)  # Reset the file pointer to the beginning

    # Iterate over each row in the CSV file
    for row in csv_reader:
        # Check if "Install Before" contains "EET"
        if 'EET' in row['Install Before']:
            # Output ".tp2", "Mod Name", and "Install Before" columns with alignment
            print(f"{row['.tp2']:<20} Mod Name: {row['Mod Name']:<{max_mod_name_length}} Install Before: {row['Install Before']:<{max_install_before_length}}")