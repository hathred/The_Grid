import sys
import os

def generate_file(template_path, output_path, replacements):
    """
    Reads a template file, performs token replacements, and writes the final file.
    """
    
    # --- 1. READ TEMPLATE FILE (Added Debugging) ---
    try:
        # This confirms that the script is finding and opening the .tpl file.
        print(f"[DEBUG] Reading template: {os.path.basename(template_path)}")
        with open(template_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"ERROR: Template file not found at {template_path}")
        return False
    except Exception as e:
        print(f"ERROR: Failed to read template {template_path}: {e}")
        return False

    final_content = content
    
    # --- 2. PERFORM REPLACEMENTS ---
    
    # Sort replacements by token length (longest first) to ensure tokens like 
    # __LOG_DIR__ are replaced before __INSTALL_ROOT__ if one is a substring of the other.
    sorted_replacements = sorted(replacements.items(), key=lambda item: len(item[0]), reverse=True)
    
    # Note: Tokens in the template often use Windows backslashes (e.g., in 3_run_pipeline_full.bat.tpl: \Python\python.exe)
    # The replacement logic must handle this.
    for token, value in sorted_replacements:
        # Replace the token with the resolved value in the content
        final_content = final_content.replace(token, value)
    
    # --- 3. WRITE FINAL FILE ---
    try:
        # Ensure the output directory exists
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        # LOG ADDED: Explicitly mark the start of writing
        print(f"[INFO] Creation START for: {os.path.basename(output_path)}")
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(final_content)
        
        # LOG ADDED: This log confirms successful creation and prints the full, resolved output path.
        print(f"[INFO] Successfully created file: {output_path}")
        
        # LOG ADDED: Explicitly mark the completion of writing
        print(f"[INFO] Creation FINISH for: {os.path.basename(output_path)}")
        return True

    except Exception as e:
        print(f"ERROR: Failed to write output file {output_path}: {e}")
        # Added a check to print the directory path that failed
        print(f"ERROR DETAILS: Output directory attempted was {os.path.dirname(output_path)}")
        return False

def main():
    # Arguments expected: 
    # [1] template_path, [2] output_path, [3...] TOKEN=VALUE pairs
    if len(sys.argv) < 3:
        print("Usage: python template_gen.py <template_path> <output_path> [TOKEN=VALUE...]")
        sys.exit(1)

    template_path = sys.argv[1]
    output_path = sys.argv[2]
    
    replacements = {}
    
    # Process environment variable arguments (TOKEN=VALUE pairs)
    for arg in sys.argv[3:]:
        if '=' in arg:
            key, value = arg.split('=', 1)
            # Normalize to the __TOKEN__ format used in templates
            replacements[f"__{key.strip().upper()}__"] = value.strip()
            
    success = generate_file(template_path, output_path, replacements)
    
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
