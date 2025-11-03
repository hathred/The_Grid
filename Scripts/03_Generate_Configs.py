import os
import sys
import subprocess
import yaml
from datetime import datetime

# ===============================================================================
# 3. Dynamic File Generation (Templating)
# This script reads the ecosystem mapping, iterates over template folders,
# and calls template_gen.py to generate configuration files into the
# corresponding target directories within the ecosystem root.
#
# Arguments (passed via command line):
# [1] INSTALL_ROOT, [2] OFFLINE_FILES, [3] LOG_DIR,
# [4] PYTHON_SCRIPTS_DIR, [5] TEMPLATE_DIR, [6] TARGET_ECOSYSTEM_ROOT
# ===============================================================================

# --- Global Paths (Will be set by command-line arguments) ---
INSTALL_ROOT = ""
OFFLINE_FILES = ""
LOG_DIR = ""
PYTHON_SCRIPTS_DIR = ""
TEMPLATE_DIR = ""
TARGET_ECOSYSTEM_ROOT = ""

def log(message):
    """Simple logging function to write a timestamped message to the log file and console."""
    if not LOG_DIR:
        print(f"[LOG ERROR] LOG_DIR is not defined. Message: {message}")
        return
    
    # Use a fixed log file name within the provided LOG_DIR
    log_file_path = os.path.join(LOG_DIR, 'install_debug.log')
    timestamp = datetime.now().strftime("[%a %m/%d/%Y %H:%M:%S.%f]"[:-4])
    log_message = f"{timestamp} {message}\n"
    
    try:
        with open(log_file_path, 'a', encoding='utf-8') as f:
            f.write(log_message)
    except Exception as e:
        print(f"[FATAL LOG ERROR] Could not write to log file {log_file_path}: {e}. Original message: {message}")


def main():
    global INSTALL_ROOT, OFFLINE_FILES, LOG_DIR, PYTHON_SCRIPTS_DIR, TEMPLATE_DIR, TARGET_ECOSYSTEM_ROOT
    
    # --- A. Argument Validation and Assignment ---
    if len(sys.argv) < 7:
        print("Usage: python 03_Generate_Configs.py <INSTALL_ROOT> <OFFLINE_FILES> <LOG_DIR> <PYTHON_SCRIPTS_DIR> <TEMPLATE_DIR> <TARGET_ECOSYSTEM_ROOT>")
        log("FATAL ERROR: Missing required command-line arguments for 03_Generate_Configs.py.")
        sys.exit(1)

    # Assign paths and ensure consistency (remove trailing separators and then add OS-specific separator)
    INSTALL_ROOT = sys.argv[1].strip().rstrip('\\/') + os.sep
    OFFLINE_FILES = sys.argv[2].strip().rstrip('\\/') + os.sep
    LOG_DIR = sys.argv[3].strip().rstrip('\\/') + os.sep
    PYTHON_SCRIPTS_DIR = sys.argv[4].strip().rstrip('\\/') + os.sep
    TEMPLATE_DIR = sys.argv[5].strip().rstrip('\\/') + os.sep
    TARGET_ECOSYSTEM_ROOT = sys.argv[6].strip().rstrip('\\/') + os.sep
    
    log("Starting Dynamic File Generation (03_Generate_Configs.py)")
    print("\n=================================================================================")
    print("3. Dynamic File Generation (Templating)")
    print("=================================================================================")
    
    # --- B. Define File Paths ---
    TEMPLATE_GEN_SCRIPT = os.path.join(PYTHON_SCRIPTS_DIR, 'template_gen.py')
    MAPPING_FILE = os.path.join(TEMPLATE_DIR, 'Ecosystem_Mapping.yml')
    # Assumes python.exe is installed directly under a 'Python' folder inside INSTALL_ROOT
    PYTHON_EXE_PATH = os.path.join(INSTALL_ROOT, 'Python', 'python.exe')
    
    if not os.path.exists(TEMPLATE_GEN_SCRIPT):
        print(f"[ERROR] Python templating script not found: {TEMPLATE_GEN_SCRIPT}")
        log(f"FATAL ERROR: template_gen.py not found at {TEMPLATE_GEN_SCRIPT}")
        sys.exit(1)
        
    if not os.path.exists(MAPPING_FILE):
        print(f"[ERROR] Mapping file not found: {MAPPING_FILE}")
        log(f"ERROR: Ecosystem_Mapping.yml not found at {MAPPING_FILE}")
        sys.exit(1)

    # --- C. Load Mapping ---
    print(f"\nReading ecosystem mapping from {os.path.basename(MAPPING_FILE)}...")
    try:
        with open(MAPPING_FILE, 'r', encoding='utf-8') as f:
            mapping_data = yaml.safe_load(f) or {}
    except yaml.YAMLError as e:
        print(f"[FATAL ERROR] Failed to parse YAML mapping file: {e}")
        log(f"FATAL ERROR: Failed to parse YAML mapping file: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"[FATAL ERROR] Failed to read mapping file: {e}")
        log(f"FATAL ERROR: Failed to read mapping file: {e}")
        sys.exit(1)

    # --- D. Iterate and Generate Files ---
    total_generated = 0
    
    for template_folder, target_segment in mapping_data.items():
        try:
            if not isinstance(template_folder, str) or not isinstance(target_segment, str):
                print(f"[WARNING] Skipping malformed mapping entry (non-string key/value).")
                log(f"WARNING: Skipping malformed mapping entry: {template_folder}={target_segment}")
                continue

            template_folder = template_folder.strip()
            target_segment = target_segment.strip()
            
            # 1. Define Target Path and Source Directory
            TARGET_PATH = os.path.join(TARGET_ECOSYSTEM_ROOT, target_segment)
            SOURCE_TEMPLATE_DIR = os.path.join(TEMPLATE_DIR, template_folder)
            
            print(f"\nProcessing Template Folder: {template_folder}")
            print(f"-> Target Segment: {target_segment}")
            
            # 2. Create Target Directory
            if not os.path.exists(TARGET_PATH):
                print(f"  [ACTION] Creating target directory: {TARGET_PATH}")
                os.makedirs(TARGET_PATH, exist_ok=True)
                log(f"SUCCESS: Created target directory: {TARGET_PATH}")

            # 3. Find Templates
            if not os.path.isdir(SOURCE_TEMPLATE_DIR):
                print(f"  [WARNING] Template source directory not found: {os.path.basename(SOURCE_TEMPLATE_DIR)}. Skipping.")
                log(f"WARNING: Template source directory not found: {SOURCE_TEMPLATE_DIR}. Skipping.")
                continue
                
            tpl_files = [f for f in os.listdir(SOURCE_TEMPLATE_DIR) if f.endswith('.tpl')]
            
            if not tpl_files:
                print(f"  [INFO] No .tpl files found in {os.path.basename(SOURCE_TEMPLATE_DIR)}. Skipping.")
                log(f"INFO: No .tpl files found in {os.path.basename(SOURCE_TEMPLATE_DIR)}. Skipping.")
                continue
            
            # 4. Execute template_gen.py for each template
            for tpl_filename in tpl_files:
                template_file_path = os.path.join(SOURCE_TEMPLATE_DIR, tpl_filename)
                output_name_without_ext = os.path.splitext(tpl_filename)[0]
                output_path_full = os.path.join(TARGET_PATH, output_name_without_ext)
                
                print(f"  -> Generating: {tpl_filename} -> {output_name_without_ext}")
                
                # Construct command for template_gen.py
                command = [
                    PYTHON_EXE_PATH,
                    TEMPLATE_GEN_SCRIPT,
                    template_file_path,
                    output_path_full,
                    f'INSTALL_ROOT={INSTALL_ROOT}',
                    f'OFFLINE_FILES={OFFLINE_FILES}',
                    f'LOG_DIR={LOG_DIR}'
                ]
                
                # Execute the templating script
                result = subprocess.run(
                    command,
                    check=True, # Raise CalledProcessError if return code is non-zero
                    capture_output=True,
                    text=True,
                    encoding='utf-8'
                )
                
                # Log template_gen.py's output
                if result.stdout:
                    for line in result.stdout.strip().split('\n'):
                        log(f"   [template_gen.py] {line}")
                
                print(f"  [SUCCESS] File created: {output_path_full}")
                log(f"SUCCESS: Generated {tpl_filename} to {output_path_full}")
                total_generated += 1
                
        except subprocess.CalledProcessError as e:
            # Handle failure from template_gen.py
            print(f"  [ERROR] Templating failed for {tpl_filename}. Check template_gen.py output/logs.")
            print(f"  template_gen.py STDERR:\n{e.stderr}")
            log(f"ERROR: Templating Failed for {tpl_filename} (Template: {template_folder}). Error: {e.stderr.strip()}")
            
        except FileNotFoundError:
            # Handle if python.exe or template_gen.py is missing
            print(f"  [FATAL ERROR] Cannot execute command. Check path for Python interpreter ({PYTHON_EXE_PATH}).")
            log(f"FATAL ERROR: Cannot execute command. Check path for Python interpreter ({PYTHON_EXE_PATH}).")
            break # Stop processing all templates
        
    print("\n=================================================================================")
    print(f"Dynamic File Generation finished. Total files generated: {total_generated}")
    log("Dynamic File Generation finished")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\n[CRITICAL PYTHON ERROR] An unhandled exception occurred in 03_Generate_Configs.py: {e}")
        log(f"CRITICAL PYTHON ERROR: Unhandled exception: {e}")
        sys.exit(1)
