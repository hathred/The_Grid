:: WARNING: This is a generated template from yaml_pretty_print.py (Source Folder: 990_Project_Automation_Automation_Scripts)
:: Check the token replacements (__XXX__) for correctness.

import yaml
import sys
import os

def pretty_print_yaml(input_file_path):
    """
    Reads a YAML file, loads its contents, and dumps it back to the console
    in a clean, readable format with proper indentation.
    """
    # 1. Check if the file exists
    if not os.path.exists(input_file_path):
        print(f"Error: Input file not found at '{input_file_path}'")
        sys.exit(1)

    try:
        # 2. Read and load the YAML content
        with open(input_file_path, 'r') as f:
            data = yaml.safe_load(f)

        # 3. Dump the data back to the console in a readable format
        # The 'sort_keys=False' ensures the output order matches the input order (good for manifests)
        # The default indentation (indent=2) makes it look clean.
        print(f"\n--- Pretty Print of: {os.path.basename(input_file_path)} ---")
        yaml_output = yaml.dump(data, sort_keys=False, indent=2, default_flow_style=False)
        print(yaml_output)
        print("--------------------------------------------------\n")

    except yaml.YAMLError as e:
        print(f"Error: Failed to parse YAML content in '{input_file_path}'")
        print(f"YAML Parsing Error Details:\n{e}")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    # Expects the file path as the first command-line argument
    if len(sys.argv) < 2:
        print("Usage: python yaml_pretty_print.py <path_to_yaml_file>")
        print("\nExample: python yaml_pretty_print.py PROJECT_MANIFEST.yaml")
        sys.exit(1)

    yaml_file_path = sys.argv[1]
    pretty_print_yaml(yaml_file_path)
