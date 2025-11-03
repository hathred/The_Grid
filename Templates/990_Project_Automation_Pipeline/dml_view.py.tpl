:: WARNING: This is a generated template from dml_view.py (Source Folder: 990_Project_Automation_Pipeline)
:: Check the token replacements (__XXX__) for correctness.

#!/usr/bin/env python3
"""
DML Viewer - Decode and pretty-print .dml.b64 files
"""
import json
import gzip
import base64
import sys
from pathlib import Path

def decode_dml(file_path):
    try:
        dml = json.load(open(file_path, 'r', encoding='utf-8'))
        raw = gzip.decompress(base64.b64decode(dml['data'])).decode('utf-8')
        print(f"Source: {dml['source']}\n")
        print(raw)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python dml_view.py <file.dml.b64>")
        sys.exit(1)
    decode_dml(sys.argv[1])