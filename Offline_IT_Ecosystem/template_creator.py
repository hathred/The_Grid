import os
import sys

# --- CONFIGURATION (Dynamically Derived from Script Location) ---

# Get the base directory (e.g., E:\NextGen) from the script's path (E:\NextGen\Scripts\...)
BASE_PATH = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Define key directory paths relative to BASE_PATH
ECOSYSTEM_ROOT = os.path.join(BASE_PATH, 'Offline_IT_Ecosystem')
TEMPLATES_ROOT = os.path.join(BASE_PATH, 'Templates')
CONFIG_FILE_PATH = os.path.join(BASE_PATH, 'config.txt')

# Define the new YAML mapping file path
MAPPING_FILE = os.path.join(TEMPLATES_ROOT, 'Ecosystem_Mapping.yml') # Changed to .yml

# Dictionary that will hold the final runtime mapping: 
# { 'D:\The_Grid': '__INSTALL_ROOT__', 'D:\The_Grid\Logs': '__LOG_DIR__', ... }
HARDCODED_PATHS_TO_REPLACE = {}


def load_paths_from_config():
    """
    Reads config.txt and generates the primary hard-path to token replacement map.
    The map is inverted: {absolute_path: __TOKEN__}
    """
    print(f"Attempting to load hard paths from: {CONFIG_FILE_PATH}")
    config_paths = {}
    
    if not os.path.exists(CONFIG_FILE_PATH):
        print(f"Warning: Config file not found at {CONFIG_FILE_PATH}. Using only structural defaults.")
        return {}

    # First Pass: Read all key=value pairs
    with open(CONFIG_FILE_PATH, 'r') as f:
        for line in f:
            line = line.strip()
            if '=' in line and not line.startswith('#'):
                try:
                    key, value = line.split('=', 1)
                    config_paths[key.strip()] = value.strip()
                except ValueError:
                    continue # Skip lines without a clear assignment

    replacement_map = {}
    
    # Resolve the INSTALL_ROOT path first, as others depend on it
    install_root_path = config_paths.get('INSTALL_ROOT')
    
    if install_root_path:
        # 1. Map the primary installation root path
        replacement_map[install_root_path] = '__INSTALL_ROOT__'
        
        # 2. Map other simple paths (like OFFLINE_FILES)
        for key, value in config_paths.items():
            # Check if path seems simple/absolute (does not contain variable substitution)
            if not ('%' in value or '!' in value):
                replacement_map[value] = f'__{key}__'

        # 3. Resolve and map dependent paths (like LOG_DIR)
        for key, value in config_paths.items():
            if value.startswith('%INSTALL_ROOT%'):
                # This logic emulates Batch variable expansion for the hard path found in config
                abs_path = value.replace('%INSTALL_ROOT%', install_root_path)
                replacement_map[abs_path] = f'__{key}__'
                
    return replacement_map


def load_existing_mapping():
    """Reads the existing Ecosystem_Mapping.yml into a dictionary."""
    mapping = {}
    if os.path.exists(MAPPING_FILE):
        # FIX: Ensure UTF-8 reading for the mapping file
        with open(MAPPING_FILE, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                # Use key=value parsing for reliability, ignoring comments
                if '=' in line and not line.startswith('#'):
                    try:
                        template_folder, parent_segment = line.split('=', 1)
                        mapping[template_folder.strip()] = parent_segment.strip()
                    except ValueError:
                        print(f"Skipping malformed line in mapping file: {line}")
    return mapping

def update_mapping_file(mapping):
    """Writes the current mapping dictionary back to the Ecosystem_Mapping.yml file."""
    print(f"\nWriting updated mapping to {MAPPING_FILE}...")
    # NOTE: Using 'w', encoding='utf-8' for the YAML file to handle any non-ASCII comments
    with open(MAPPING_FILE, 'w', encoding='utf-8') as f:
        # Write YAML-like structure headers
        f.write("# ECOSYSTEM MAPPING CONFIGURATION (YAML Format)\n")
        f.write("# ---------------------------------------------------------------------------------\n")
        f.write("# Format: [UniqueTemplateFolder]=[TargetParentSegment]\n")
        f.write("# (Example: 210_Project_Dev_Tools_Summarize=210_Project_Dev_Tools)\n")
        f.write("# ---------------------------------------------------------------------------------\n")
        
        for template_folder, parent_segment in sorted(mapping.items()):
            # Using key=value for reliable parsing in the Batch script later
            f.write(f"{template_folder}={parent_segment}\n")
    print("Mapping file updated successfully.")


def create_template_from_script(script_path, template_folder):
    """
    Reads a script, performs token replacement, and writes the new template file.
    Uses the dynamically populated HARDCODED_PATHS_TO_REPLACE global map.
    
    The template_folder here is the UNIQUE one (e.g., '210_Project_Dev_Tools_Summarize').
    """
    try:
        # 1. Read original script content (using UTF-8)
        with open(script_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 2. Perform string replacements (most specific replacements first)
        # Sort by length descending to ensure longer paths (like D:\The_Grid\Logs) 
        # are replaced before their parent paths (like D:\The_Grid)
        sorted_replacements = sorted(
            HARDCODED_PATHS_TO_REPLACE.items(), 
            key=lambda item: len(item[0]), 
            reverse=True
        )

        for hard_path, token in sorted_replacements:
            # We also ensure all path separators are consistent for replacement 
            # (replace both / and \ with os.path.sep before comparison)
            content = content.replace(hard_path.replace('/', os.path.sep).replace('\\', os.path.sep), token)
        
        # 3. Determine new template file path
        script_filename = os.path.basename(script_path)
        template_filename = f"{script_filename}.tpl"

        # template_folder is already the unique name (e.g., 210_Project_Dev_Tools_Scripts)
        template_dir = os.path.join(TEMPLATES_ROOT, template_folder)
        os.makedirs(template_dir, exist_ok=True)
        
        template_path = os.path.join(template_dir, template_filename)

        # 4. Write new template content (using UTF-8)
        with open(template_path, 'w', encoding='utf-8') as f:
            # Added helpful comment for the new unique template name
            f.write(f":: WARNING: This is a generated template from {script_filename} (Source Folder: {template_folder})\n")
            f.write(":: Check the token replacements (__XXX__) for correctness.\n\n")
            f.write(content)
        
        print(f"  [CREATED] -> {template_path}")
        return True

    except Exception as e:
        print(f"  [ERROR] Failed to process {script_path}: {e}")
        return False


def main():
    global HARDCODED_PATHS_TO_REPLACE
    
    # 1. Load dynamic paths from config.txt and populate the global replacement map
    config_map = load_paths_from_config()
    HARDCODED_PATHS_TO_REPLACE.update(config_map)

    # 2. Add structural path for the installer root itself
    # This token replaces the absolute path of the root folder (E:\NextGen\Offline_IT_Ecosystem)
    HARDCODED_PATHS_TO_REPLACE[ECOSYSTEM_ROOT] = '__ECOSYSTEM_ROOT__'


    if not os.path.exists(ECOSYSTEM_ROOT):
        print(f"Error: Ecosystem root path not found: {ECOSYSTEM_ROOT}")
        print("Please ensure your project structure is correct.")
        sys.exit(1)

    existing_mapping = load_existing_mapping()
    newly_discovered_mappings = {}
    generated_count = 0

    print(f"Scanning scripts in: {ECOSYSTEM_ROOT}...\n")
    
    for root, dirs, files in os.walk(ECOSYSTEM_ROOT):
        relative_path = os.path.relpath(root, ECOSYSTEM_ROOT)
        parts = relative_path.split(os.path.sep)

        # Target structure is PARENT_SEGMENT/TEMPLATE_FOLDER (depth >= 2)
        if len(parts) >= 2 and parts[0] != '.':
            parent_segment = parts[-2]
            local_template_folder_name = parts[-1]
            
            # --- FIX: Create a unique template folder name ---
            # e.g., 'Summarize' -> '210_Project_Dev_Tools_Summarize'
            unique_template_folder = f"{parent_segment}_{local_template_folder_name}"
            
            if unique_template_folder not in existing_mapping:
                 newly_discovered_mappings[unique_template_folder] = parent_segment

            for filename in files:
                # Process common script extensions
                if filename.endswith(('.bat', '.ps1', '.py')):
                    script_path = os.path.join(root, filename)
                    if create_template_from_script(script_path, unique_template_folder): # Use unique name
                        generated_count += 1
    
    # Merge newly discovered mappings with existing ones
    for folder, segment in newly_discovered_mappings.items():
        if folder not in existing_mapping:
            existing_mapping[folder] = segment
    
    update_mapping_file(existing_mapping)

    print(f"\n--- Complete ---")
    print(f"Total templates generated: {generated_count}")
    print(f"New folders added to mapping: {len(newly_discovered_mappings)}")
    
    print("\n[DEBUG] Hard Path Replacement Map:")
    for hard_path, token in HARDCODED_PATHS_TO_REPLACE.items():
        print(f"  '{hard_path}' -> '{token}'")


if __name__ == "__main__":
    main()