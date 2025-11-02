"""
DML Encoder Module
Converts cleaned Python dict → DML (JSON + gzip + base64)
"""

import json
import gzip
import base64
import logging
from pathlib import Path
from typing import Dict, Any

logger = logging.getLogger(__name__)

class DMLEncoder:
    def __init__(self, config):
        self.config = config
        self.use_compression = config.get('encoding', {}).get('compress', True)

    def encode_to_dml(self, data: Dict[str, Any]) -> str:
        """
        Encode dict → DML string
        Steps:
          1. json.dumps(data)
          2. (optional) gzip.compress
          3. base64.b64encode
        """
        try:
            # Step 1: Serialize to JSON string
            json_str = json.dumps(data, ensure_ascii=False, separators=(',', ':'))
            json_bytes = json_str.encode('utf-8')

            # Step 2: Optional gzip compression
            if self.use_compression:
                compressed_bytes = gzip.compress(json_bytes)
            else:
                compressed_bytes = json_bytes

            # Step 3: Base64 encode
            encoded_b64 = base64.b64encode(compressed_bytes).decode('ascii')

            # Wrap in DML envelope
            dml_envelope = {
                "dml_version": "1.0",
                "source": data.get("filename", "unknown"),
                "timestamp": data.get("timestamp", "1970-01-01T00:00:00"),
                "compressed": self.use_compression,
                "data": encoded_b64
            }

            # Final JSON string
            final_json = json.dumps(dml_envelope, separators=(',', ':'))
            return final_json

        except Exception as e:
            logger.error(f"DML encoding failed: {str(e)}")
            raise

    def write_dml_file(self, output_path: Path, dml_string: str):
        """Write DML string to .dml.b64 file"""
        try:
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_text(dml_string, encoding='utf-8')
        except Exception as e:
            logger.error(f"Failed to write {output_path}: {str(e)}")
            raise