:: WARNING: This is a generated template from config_manager.py (Source Folder: 990_Project_Automation_Pipeline)
:: Check the token replacements (__XXX__) for correctness.

"""
Configuration Manager
Handles loading and accessing configuration from YAML files
"""

import yaml
import logging
from pathlib import Path
from typing import Any, Dict

logger = logging.getLogger(__name__)

# In config_manager.py
def get(self, key, default=None):
    return self.config.get(key, default)

class ConfigManager:
    """Manages configuration loading and access"""
    
    def __init__(self, config_path: str = 'config.yaml'):
        self.config_path = Path(config_path)
        self.config = self._load_config()
    
    def _load_config(self) -> Dict:
        """Load configuration from YAML file"""
        try:
            if not self.config_path.exists():
                logger.warning(f"Config file not found: {self.config_path}, using defaults")
                return self._get_default_config()
            
            with open(self.config_path, 'r', encoding='utf-8') as f:
                config = yaml.safe_load(f)
            
            logger.info(f"Loaded configuration from {self.config_path}")
            return config
        
        except Exception as e:
            logger.error(f"Failed to load config: {str(e)}, using defaults")
            return self._get_default_config()
    
    def _get_default_config(self) -> Dict:
        """Return default configuration"""
        return {
            'paths': {
                'content_root': 'E:/NextGen/Offline_IT_Ecosystem/200_Content_Data_Source',
                'output_root': 'E:/NextGen/Offline_IT_Ecosystem/210_Project_Dev_Tools/Summarize/output'
            },
            'file_patterns': ['*.json', '*.yaml', '*.yml', '*.txt', '*.md'],
            'key_mappings': {
                # MTG/Scryfall mappings
                'name': 'n',
                'mana_cost': 'mc',
                'cmc': 'cmc',
                'type_line': 'tc',
                'oracle_text': 'ot',
                'colors': 'c',
                'color_identity': 'ci',
                'set': 's',
                'set_name': 'sn',
                'rarity': 'r',
                'power': 'p',
                'toughness': 't',
                'loyalty': 'l',
                'flavor_text': 'ft',
                'artist': 'a',
                'collector_number': 'cn',
                'released_at': 'rd',
                
                # Generic mappings
                'description': 'd',
                'title': 't',
                'content': 'c',
                'timestamp': 'ts',
                'author': 'au',
                'source': 'src'
            },
            'processing': {
                'max_file_size_mb': 100,
                'text_chunk_size': 5000,
                'enable_compression': True
            }
        }
    
    def get(self, key_path: str, default: Any = None) -> Any:
        """
        Get configuration value using dot notation
        Example: config.get('paths.content_root')
        """
        keys = key_path.split('.')
        value = self.config
        
        try:
            for key in keys:
                value = value[key]
            return value
        except (KeyError, TypeError):
            return default
    
    def save_config(self, filepath: str = None):
        """Save current configuration to YAML file"""
        if filepath is None:
            filepath = self.config_path
        
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                yaml.dump(self.config, f, default_flow_style=False, allow_unicode=True)
            
            logger.info(f"Saved configuration to {filepath}")
        
        except Exception as e:
            logger.error(f"Failed to save config: {str(e)}")
