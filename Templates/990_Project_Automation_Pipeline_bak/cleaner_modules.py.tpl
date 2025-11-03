:: WARNING: This is a generated template from cleaner_modules.py (Source Folder: 990_Project_Automation_Pipeline_bak)
:: Check the token replacements (__XXX__) for correctness.

"""
Data Cleaner Module
Loads, cleans, and normalizes data for DML encoding
"""

import re
import yaml
import json
import logging
from pathlib import Path
from typing import Any, Dict, Optional

logger = logging.getLogger(__name__)

class DataCleaner:
    def __init__(self, config):
        self.config = config
        self.key_map = config.get('key_mappings', {})
        self.reverse_map = {v: k for k, v in self.key_map.items()}

    def load_raw_data(self, filepath: Path) -> Optional[Dict]:
        """
        Load and parse file based on extension
        Supports: .json, .yaml/.yml, .txt, .md
        Returns: Python dict or None on failure
        """
        try:
            # Read with UTF-8 fallback
            try:
                content = filepath.read_text(encoding='utf-8')
            except UnicodeDecodeError:
                content = filepath.read_text(encoding='utf-8', errors='replace')
            
            # Remove BOM
            content = content.lstrip('\ufeff')
            
            suffix = filepath.suffix.lower()
            
            if suffix == '.json':
                return json.loads(content)
            
            elif suffix in {'.yaml', '.yml'}:
                return yaml.safe_load(content) or {}
            
            elif suffix in {'.txt', '.md'}:
                return {
                    "content": content,
                    "filename": filepath.name,
                    "path": str(filepath),
                    "type": "text"
                }
            
            else:
                logger.warning(f"Unsupported file type: {suffix}")
                return None
                
        except Exception as e:
            logger.error(f"Failed to load {filepath}: {str(e)}")
            return None

    def clean_data(self, data: Any) -> Dict:
        """Recursively clean and normalize data"""
        if isinstance(data, dict):
            cleaned = {}
            for k, v in data.items():
                # Skip comment-like keys
                if str(k).strip().startswith(('#', '//', '/*')):
                    continue
                # Normalize key
                clean_key = self.key_map.get(k, k)
                cleaned[clean_key] = self.clean_data(v)
            return cleaned
        elif isinstance(data, list):
            return [self.clean_data(item) for item in data]
        else:
            return data

    def clean_and_standardize(self, filepath: Path) -> Optional[Dict]:
        """
        Public method called by grok_main.py
        Load → Clean → Return dict
        """
        raw = self.load_raw_data(filepath)
        if raw is None:
            return None
        return self.clean_data(raw)