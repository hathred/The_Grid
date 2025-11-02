#!/usr/bin/env python3
"""
DML Archive Builder - --archive mode
Usage: python archive_builder.py --archive
Output: dml_archive_YYYYMMDD_HHMMSS.zip
"""

import json
import zipfile
from pathlib import Path
from datetime import datetime
import gzip
import base64

DML_ROOT = Path(r"E:\NextGen\Offline_IT_Ecosystem\210_Project_Dev_Tools\Summarize\output")
ARCHIVE_ROOT = Path(r"E:\NextGen\Offline_IT_Ecosystem\995_Project_Logs\DML_Archives")

def build_archive():
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    archive_name = f"dml_archive_{timestamp}"
    archive_path = ARCHIVE_ROOT / f"{archive_name}.zip"
    ARCHIVE_ROOT.mkdir(parents=True, exist_ok=True)

    manifest = {
        "archive_name": archive_name,
        "generated_at": datetime.now().isoformat(),
        "dml_count": 0,
        "total_size_bytes": 0,
        "files": []
    }

    with zipfile.ZipFile(archive_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        dml_files = list(DML_ROOT.rglob("*.dml.b64"))
        manifest["dml_count"] = len(dml_files)

        for dml_file in dml_files:
            rel_path = dml_file.relative_to(DML_ROOT)
            arc_name = f"dml_files/{rel_path.as_posix()}"
            zf.write(dml_file, arc_name)

            # Add to manifest
            size = dml_file.stat().st_size
            manifest["total_size_bytes"] += size
            manifest["files"].append({
                "path": str(rel_path),
                "size": size,
                "source": dml_file.stem  # e.g., manifest.yml
            })

        # Write MANIFEST.json
        zf.writestr("MANIFEST.json", json.dumps(manifest, indent=2))

        # Write SUMMARY.md
        summary = f"""# DML Archive: {archive_name}

**Generated:** {manifest['generated_at']}  
**DML Count:** {manifest['dml_count']}  
**Total Size:** {manifest['total_size_bytes']:,} bytes  

## Files
"""
        for f in manifest["files"]:
            summary += f"- `{f['path']}` ({f['size']:,} bytes) ← `{f['source']}`\n"
        zf.writestr("SUMMARY.md", summary)

    print(f"ARCHIVE CREATED: {archive_path}")
    print(f"   DMLs: {manifest['dml_count']} | Size: {manifest['total_size_bytes']:,} bytes")
    return archive_path

if __name__ == "__main__":
    build_archive()