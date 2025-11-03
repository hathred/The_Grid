import sys
import yaml

def read_yaml_mapping(filepath):
    """
    Reads the Ecosystem_Mapping.yml and prints key=value pairs for
    consumption by a Windows batch script's FOR loop.
    
    Format: [UniqueTemplateFolder]=[TargetParentSegment]
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            # Load the YAML content
            data = yaml.safe_load(f)
            
            # The YAML is expected to be a simple dictionary mapping.
            if isinstance(data, dict):
                for template_folder, parent_segment in data.items():
                    # Print in 'key=value' format, which the batch script
                    # can easily parse with 'tokens=1,2 delims=='
                    print(f"{template_folder}={parent_segment}")
            else:
                print(f"ERROR: YAML content in {filepath} is not a dictionary.", file=sys.stderr)
                sys.exit(1)
                
    except FileNotFoundError:
        print(f"ERROR: Mapping file not found at {filepath}", file=sys.stderr)
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"ERROR: Failed to parse YAML file {filepath}: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: An unexpected error occurred in yaml_reader: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        # We expect one argument: the path to the YAML file
        print("Usage: python yaml_reader.py <path_to_mapping.yml>", file=sys.stderr)
        sys.exit(1)
        
    mapping_file_path = sys.argv[1]
    read_yaml_mapping(mapping_file_path)
