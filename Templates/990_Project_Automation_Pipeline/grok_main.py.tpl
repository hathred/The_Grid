:: WARNING: This is a generated template from grok_main.py (Source Folder: 990_Project_Automation_Pipeline)
:: Check the token replacements (__XXX__) for correctness.

#!/usr/bin/env python3
"""
Grok: Summarize - DML Pipeline Orchestrator
Main entry point for data processing, cleaning, and encoding
"""
from pathlib import Path
import argparse
import logging
import sys
from datetime import datetime
import yaml

# Local imports (these will be in the same src/ directory)
from cleaner_modules import DataCleaner
from dml_encoder import DMLEncoder
from config_manager import ConfigManager

class GrokPipeline:
    """Main orchestrator for the DML data processing pipeline"""
    
    def __init__(self, config_path='config.yaml', dry_run=False, force=False, clean_mode=False, stats=False):
        self.config = ConfigManager(config_path)
        self.dry_run = dry_run
        self.force = force
        self.clean_mode = clean_mode        # ← NOW BOUND
        self.stats = stats
        self.cleaner = DataCleaner(self.config)
        self.encoder = DMLEncoder(self.config)
        
        # Setup logging
        self._setup_logging()
        
        self.stats = {
            'processed': 0,
            'skipped': 0,
            'failed': 0,
            'bytes_saved': 0
        }
    
    def _setup_logging(self):
        """Configure logging with file and console output"""
        log_dir = Path('E:/NextGen/Offline_IT_Ecosystem/995_Project_Logs')
        log_dir.mkdir(parents=True, exist_ok=True)
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        log_file = log_dir / f'grok_pipeline_{timestamp}.log'
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s [%(levelname)s] %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger(__name__)
        self.logger.info(f"Pipeline initialized (dry_run={self.dry_run}, force={self.force})")
    
    def should_process_file(self, source_path, target_path):
        """Determine if a file needs processing based on timestamps"""
        if self.force:
            return True
        
        if not target_path.exists():
            return True
        
        source_mtime = source_path.stat().st_mtime
        target_mtime = target_path.stat().st_mtime
        
        return source_mtime > target_mtime
    
    def discover_files(self):
        """Recursively discover files in dirs with DIRECTORY_MANIFEST.md"""
        content_root = Path(self.config.get('paths.content_root'))
        discovered = []
        manifest_name = "DIRECTORY_MANIFEST.md"

        # Find all dirs with manifest
        for manifest_path in content_root.rglob(manifest_name):
            dir_path = manifest_path.parent
            if not dir_path.is_dir():
                continue

            # Process all files in this dir (and subdirs)
            for pattern in self.config.get('file_patterns', ['*.json', '*.yaml', '*.txt', '*.md']):
                for file_path in dir_path.rglob(pattern):
                    # Skip excluded
                    if any(skip in str(file_path) for skip in ['bak', 'Archive', 'temp', '.git']):
                        continue
                    discovered.append(file_path)

        self.logger.info(f"Discovered {len(discovered)} files in {len(set(p.parent for p in discovered))} manifest-approved dirs")
        return discovered
    
    def process_file(self, source_path: Path) -> bool:
        """Process a single file: clean → encode → write"""
        try:
            # Calculate output path
            rel_path = source_path.relative_to(Path(self.config.get('paths.content_root')))
            output_path = Path(self.config.get('paths.output_root')) / (str(rel_path) + '.dml.b64')
            
            # Skip if up to date
            if not self.should_process_file(source_path, output_path):
                self.logger.info(f"  -> Skipped (up to date): {source_path.name}")
                self.stats['skipped'] += 1
                return True
            
            # CLEAN: Use self.cleaner
            cleaned_data = self.cleaner.clean_and_standardize(source_path)
            if cleaned_data is None:
                self.logger.error(f"  -> Failed: {source_path} - Cleaning returned None")
                self.stats['failed'] += 1
                return False
            
            # ENCODE
            original_size = source_path.stat().st_size
            encoded_data = self.encoder.encode_to_dml(cleaned_data)
            encoded_size = len(encoded_data.encode('ascii'))
            
            reduction = original_size - encoded_size
            self.stats['bytes_saved'] += reduction
            
            # Write output (unless dry run)
            if not self.dry_run:
                output_path.parent.mkdir(parents=True, exist_ok=True)
                self.encoder.write_dml_file(output_path, encoded_data)
                self.logger.info(f"  -> Success: {source_path.name} ({original_size} -> {encoded_size} bytes, -{reduction/1024:.1f}KB)")
            else:
                self.logger.info(f"  -> [DRY RUN] Would write: {output_path}")
            
            self.stats['processed'] += 1
            return True
            
        except Exception as e:
            self.logger.error(f"  -> Failed: {source_path} - {str(e)}")
            self.stats['failed'] += 1
            return False
    
    def run(self, args=None):
        self.logger.info("="*60)
        self.logger.info("GROK: SUMMARIZE - DML PIPELINE EXECUTION")
        self.logger.info("="*60)

        if self.clean_mode:
            self.clean_orphans()
            if not self.force and not self.dry_run:
                return  # Exit after clean
        if args.archive:
            from archive_builder import build_archive
            build_archive()
            return

        """Execute the complete pipeline"""
        self.logger.info("="*60)
        self.logger.info("GROK: SUMMARIZE - DML PIPELINE EXECUTION")
        self.logger.info("="*60)
        
        if self.dry_run:
            self.logger.warning("DRY RUN MODE - No files will be written")
        
        # Discover all files
        files = self.discover_files()
        
        # Process each file
        for file_path in files:
            self.process_file(file_path)
        
        # Print summary
        self.print_summary()
        if args and getattr(args, 'stats', False):
            self.generate_stats_report()

        if args and getattr(args, 'web', False):
            from web_server import app
            app.run(host="localhost", port=8000)

        if args and getattr(args, 'api', False):
            from api_server import app
            app.run(host="localhost", port=5000)

    def print_summary(self):
        """Print execution summary"""
        self.logger.info("="*60)
        self.logger.info("EXECUTION SUMMARY")
        self.logger.info("="*60)
        self.logger.info(f"Processed:   {self.stats['processed']}")
        self.logger.info(f"Skipped:     {self.stats['skipped']}")
        self.logger.info(f"Failed:      {self.stats['failed']}")
        self.logger.info(f"Space saved: {self.stats['bytes_saved']/1024/1024:.2f} MB")
        self.logger.info("="*60)
        
    def clean_orphans(self):
        """Remove .dml.b64 files whose source no longer exists"""
        if not self.clean_mode:
            return

        output_root = Path(self.config.get('paths.output_root'))
        if not output_root.exists():
            return

        self.logger.info("CLEAN MODE: Scanning for orphaned DML files...")
        deleted = 0

        for dml_file in output_root.rglob("*.dml.b64"):
            # Reconstruct expected source path
            rel = dml_file.relative_to(output_root)
            source_path = Path(self.config.get('paths.content_root')) / rel.parent / rel.stem

            if not source_path.exists():
                try:
                    dml_file.unlink()
                    self.logger.info(f"  -> DELETED orphan: {dml_file}")
                    deleted += 1
                except Exception as e:
                    self.logger.error(f"  -> Failed to delete {dml_file}: {e}")

        self.logger.info(f"CLEAN MODE: {deleted} orphaned DML files removed.")
        
    def generate_stats_report(self):
        """Generate DML_SUMMARY.md with full pipeline statistics (zero-safe)"""
        try:
            from datetime import datetime

            output_root = Path(self.config.get('paths.output_root'))
            content_root = Path(self.config.get('paths.content_root'))

            dml_files = list(output_root.rglob("*.dml.b64"))
            if not dml_files:
                self.logger.info("STATS: No DML files found.")
                return

            total_original = 0
            total_compressed = 0
            savings_list = []

            for dml_file in dml_files:
                rel = dml_file.relative_to(output_root)
                src_path = content_root / rel.parent / rel.stem

                if src_path.exists():
                    orig_size = src_path.stat().st_size
                    dml_size = dml_file.stat().st_size
                    saved = orig_size - dml_size

                    total_original += orig_size
                    total_compressed += dml_size
                    savings_list.append((saved, src_path.name, orig_size, dml_size))

            # Sort by savings
            savings_list.sort(reverse=True)
            top_5 = savings_list[:5]

            # ZERO-SAFE RATIO
            ratio = "N/A"
            if total_original > 0:
                ratio = f"{total_compressed/total_original:.1%}"

            # Build Markdown
            summary_path = output_root.parent / "DML_SUMMARY.md"
            lines = [
                "# DML Pipeline Summary\n\n",
                f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n",
                f"**Content Root:** `{content_root}`\n",
                f"**Output Root:** `{output_root}`\n\n",
                "---\n\n",
                "## Execution Summary\n",
                f"- **Processed:** {self.stats['processed']}\n",
                f"- **Skipped:** {self.stats['skipped']}\n",
                f"- **Failed:** {self.stats['failed']}\n",
                f"- **Space Saved:** {self.stats['bytes_saved']/1024/1024:.3f} MB\n\n",
                f"- **Total Original Size:** {total_original/1024/1024:.3f} MB\n",
                f"- **Total DML Size:** {total_compressed/1024/1024:.3f} MB\n",
                f"- **Compression Ratio:** {ratio}\n\n",
                "---\n\n",
                "## Top 5 Space Savers\n"
            ]

            if top_5:
                for saved, name, orig, dml in top_5:
                    lines.append(f"- `{name}`: **-{saved/1024:.1f} KB** → {dml/1024:.1f} KB (from {orig/1024:.1f} KB)\n")
            else:
                lines.append("*No source files found for comparison.*\n")

            lines.append("\n---\n*Generated by GrokPipeline --stats*")

            summary_path.write_text("".join(lines), encoding='utf-8')
            self.logger.info(f"STATS: DML_SUMMARY.md written to {summary_path}")

        except Exception as e:
            self.logger.error(f"STATS: Failed to generate report: {e}")

def main():
    """CLI entry point"""
    parser = argparse.ArgumentParser(
        description='Grok: Summarize - Offline Data Markup Language Pipeline'
    )
    parser.add_argument(
        '--config',
        default='config.yaml',
        help='Path to configuration file (default: config.yaml)'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Run without writing any output files'
    )
    parser.add_argument(
        '--force',
        action='store_true',
        help='Force reprocessing of all files, ignoring timestamps'
    )
    parser.add_argument(
        '--clean',
        action='store_true',
        help='Remove orphaned .dml.b64 files (no source)'
    )
    parser.add_argument(
        '--stats',
        action='store_true',
        help='Generate DML_SUMMARY.md with pipeline statistics'
    )
    parser.add_argument(
        '--web',
        action='store_true',
        help='Launch DML Web Dashboard'
    )
    parser.add_argument(
        '--api',
        action='store_true',
        help='Launch DML REST API Server'
    )
    parser.add_argument(
        '--archive',
        action='store_true',
        help='Build DML archive bundle (ZIP + MANIFEST + SUMMARY)'
    )
    args = parser.parse_args()
    
    # Create and run pipeline
    pipeline = GrokPipeline(
        config_path=args.config,
        dry_run=args.dry_run,
        force=args.force,
        clean_mode=args.clean
    )
    
    try:
        pipeline.run(args)
        sys.exit(0)
    except KeyboardInterrupt:
        pipeline.logger.warning("Pipeline interrupted by user")
        sys.exit(1)
    except Exception as e:
        pipeline.logger.error(f"Fatal error: {str(e)}")
        sys.exit(1)


if __name__ == '__main__':
    main()
