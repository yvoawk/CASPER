# ===============================================================================================
# CASPER version v1.0.2
# Author: Yvon K. Awuklu
# Description: Python script to filter facts from a given file based on the value of T.
# ================================================================================================

import sys
import re

TIME_VALUE_PATTERN = re.compile(r',\s*([+-]?\d+)\)\.\s*$')

def filter_facts(input_file, output_file, start, end):
    """
    Filter facts from input_file based on the value of P and write the results to output_file.
    
    Args:
        input_file (str): Path to the input file (facts.lp).
        output_file (str): Path to the output file (filtered_facts.lp).
        start (str): Start value of T to filter by.
        end (str): End value of T to filter by.
    """
    try:
        start_num = int(start)
        end_num = int(end)
    except ValueError:
        print(f"Error: Start '{start}' and end '{end}' must be integers.")
        return

    try:
        with open(input_file, "r") as infile, open(output_file, "w") as outfile:
            for line in infile:
                # Remove inline ASP comments that begin with %
                content = line.split("%", 1)[0].strip()
                if not content or not content.startswith("obs("):
                    continue

                match = TIME_VALUE_PATTERN.search(content)
                if not match:
                    continue

                last_value = match.group(1)
                try:
                    last_value_num = int(last_value)
                except ValueError:
                    print(f"Warning: Could not convert '{last_value}' to integer.")
                    continue

                if start_num <= last_value_num <= end_num:
                    outfile.write(line)
        print(f"Filtered facts have been written to {output_file}.")
    except FileNotFoundError:
        print(f"Error: The file {input_file} does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")

def main():
    # Parse command-line arguments
    input_file = sys.argv[1]  # Path to the input file
    output_file = sys.argv[2]  # Path to the output file
    start = sys.argv[3] # Start value of T
    end = sys.argv[4]   # End value of T

    # Call the filter_facts function
    filter_facts(input_file, output_file, start, end)

if __name__ == "__main__":
    main()
