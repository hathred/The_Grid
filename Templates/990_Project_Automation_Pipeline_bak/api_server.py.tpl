:: WARNING: This is a generated template from api_server.py (Source Folder: 990_Project_Automation_Pipeline_bak)
:: Check the token replacements (__XXX__) for correctness.

#!/usr/bin/env python3
"""
DML API Server - REST endpoints for DML files
Usage: python api_server.py
Base URL: http://localhost:5000/api/v1
"""

import json
import gzip
import base64
from pathlib import Path
from flask import Flask, jsonify, request, send_file, abort
from flask_cors import CORS
import time
from datetime import datetime

app = Flask(__name__)
CORS(app)  # Allow cross-origin

DML_ROOT = Path(r"__ECOSYSTEM_ROOT__\210_Project_Dev_Tools\Summarize\output")

@app.route("/api/v1/dml/<path:rel_path>")
@app.route("/api/v1/dml/<path:rel_path>")
def get_dml(rel_path):
    file_path = (DML_ROOT / rel_path).resolve()
    if not file_path.is_relative_to(DML_ROOT) or not file_path.exists():
        abort(404)

    try:
        dml = json.load(open(file_path, 'r', encoding='utf-8'))
        raw = gzip.decompress(base64.b64decode(dml['data'])).decode('utf-8')
        data = json.loads(raw)

        # --- EXTRACT & ENFORCE METADATA ---
        source = dml.get('source')
        if not source or source.strip() == "" or source == "unknown":
            # Remove .dml.b64 and keep original extension
            source = Path(rel_path).stem  # ← manifest.yml

        timestamp = dml.get('timestamp')
        if not timestamp or timestamp == "1970-01-01T00:00:00":
            timestamp = datetime.fromtimestamp(file_path.stat().st_mtime).isoformat()

        return jsonify({
            "metadata": {
                "source": source,
                "timestamp": timestamp,
                "path": str(rel_path),
                "size": file_path.stat().st_size
            },
            "data": data
        })
    except Exception as e:
        abort(500, str(e))

@app.route("/api/v1/health")
def health():
    return jsonify({"status": "healthy", "dml_count": len(list(DML_ROOT.rglob("*.dml.b64")))})

if __name__ == "__main__":
    print("DML API Server → http://localhost:5000/api/v1")
    app.run(host="0.0.0.0", port=5000, debug=False)