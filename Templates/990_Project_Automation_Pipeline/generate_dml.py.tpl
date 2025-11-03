:: WARNING: This is a generated template from generate_dml.py (Source Folder: 990_Project_Automation_Pipeline)
:: Check the token replacements (__XXX__) for correctness.

import json, gzip, base64, time
from pathlib import Path

def create_dml(content: str, source: str, output_path: Path):
    compressed = gzip.compress(content.encode('utf-8'))
    b64 = base64.b64encode(compressed).decode('utf-8')
    
    dml = {
        "source": source,
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S", time.gmtime()),
        "compressed": True,
        "data": b64
    }
    
    output_path.write_text(json.dumps(dml, indent=2))