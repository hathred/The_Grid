#!/usr/bin/env python3
"""
Project Manifest Consolidation Tool
Purpose: Merge multiple JSON files in project root into unified structure
Author: Claude + Hathred88
"""

import json
import yaml
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, List
import sys

class ManifestConsolidator:
    """Consolidates multiple JSON manifests into a unified structure"""
    
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.manifests = {}
        self.consolidated = {
            "manifest_version": "2.0",
            "project_name": "The Grid - Offline IT Ecosystem",
            "created": datetime.now().isoformat(),
            "description": {},
            "goals": {},
            "roadmap": {},
            "structure": {},
            "documentation": {},
            "handover": {},
            "mtg_collection": {},
            "onboarding": {},
            "metadata": {}
        }
    
    def load_json_files(self) -> Dict[str, Any]:
        """Load all JSON files from project root"""
        json_files = [
            "Directory_manifest.json",
            "documentation.json",
            "handover.json",
            "Mtg_Collection_Generator.json",
            "mtg-ocr-project-plan.json",
            "onboarding.json",
            "Project_Description.json",
            "project_file_structure_manifest.json",
            "Project_Goal.json",
            "Roadmap.json"
        ]
        
        print("=" * 70)
        print("LOADING JSON MANIFESTS")
        print("=" * 70)
        
        for filename in json_files:
            filepath = self.project_root / filename
            
            if not filepath.exists():
                print(f"[SKIP] Not found: {filename}")
                continue
            
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    self.manifests[filename] = data
                    
                    # Calculate size
                    size_kb = filepath.stat().st_size / 1024
                    print(f"[LOAD] {filename} ({size_kb:.1f} KB)")
                    
            except Exception as e:
                print(f"[ERROR] Failed to load {filename}: {str(e)}")
        
        print(f"\nLoaded {len(self.manifests)} manifests\n")
        return self.manifests
    
    def consolidate_project_description(self):
        """Consolidate Project_Description.json"""
        if "Project_Description.json" in self.manifests:
            data = self.manifests["Project_Description.json"]
            self.consolidated["description"] = {
                "overview": data.get("overview", ""),
                "purpose": data.get("purpose", ""),
                "scope": data.get("scope", ""),
                "target_audience": data.get("target_audience", []),
                "key_features": data.get("key_features", [])
            }
            print("[MERGE] Project_Description.json → description")
    
    def consolidate_project_goals(self):
        """Consolidate Project_Goal.json"""
        if "Project_Goal.json" in self.manifests:
            data = self.manifests["Project_Goal.json"]
            self.consolidated["goals"] = {
                "primary": data.get("primary_goal", ""),
                "secondary": data.get("secondary_goals", []),
                "success_criteria": data.get("success_criteria", []),
                "milestones": data.get("milestones", [])
            }
            print("[MERGE] Project_Goal.json → goals")
    
    def consolidate_roadmap(self):
        """Consolidate Roadmap.json"""
        if "Roadmap.json" in self.manifests:
            data = self.manifests["Roadmap.json"]
            
            # Organize by status and priority
            organized = {
                "by_status": {
                    "TODO": [],
                    "IN_PROGRESS": [],
                    "DONE": []
                },
                "by_priority": {
                    "CRITICAL": [],
                    "HIGH": [],
                    "MEDIUM": [],
                    "LOW": []
                },
                "by_domain": {},
                "by_phase": {}
            }
            
            # Process each task
            for task in data:
                status = task.get("status", "TODO")
                priority = task.get("priority", "MEDIUM")
                domain = task.get("domain", "Unknown")
                phase = task.get("phase", "Unknown")
                
                # By status
                if status in organized["by_status"]:
                    organized["by_status"][status].append(task)
                
                # By priority
                if priority in organized["by_priority"]:
                    organized["by_priority"][priority].append(task)
                
                # By domain
                if domain not in organized["by_domain"]:
                    organized["by_domain"][domain] = []
                organized["by_domain"][domain].append(task)
                
                # By phase
                if phase not in organized["by_phase"]:
                    organized["by_phase"][phase] = []
                organized["by_phase"][phase].append(task)
            
            self.consolidated["roadmap"] = organized
            print("[MERGE] Roadmap.json → roadmap (organized by status/priority/domain/phase)")
    
    def consolidate_directory_structure(self):
        """Consolidate Directory_manifest.json and project_file_structure_manifest.json"""
        structure = {}
        
        if "Directory_manifest.json" in self.manifests:
            structure["directory_manifest"] = self.manifests["Directory_manifest.json"]
            print("[MERGE] Directory_manifest.json → structure.directory_manifest")
        
        if "project_file_structure_manifest.json" in self.manifests:
            structure["file_structure"] = self.manifests["project_file_structure_manifest.json"]
            print("[MERGE] project_file_structure_manifest.json → structure.file_structure")
        
        self.consolidated["structure"] = structure
    
    def consolidate_documentation(self):
        """Consolidate documentation.json"""
        if "documentation.json" in self.manifests:
            data = self.manifests["documentation.json"]
            self.consolidated["documentation"] = {
                "guides": data.get("guides", []),
                "api_docs": data.get("api_docs", []),
                "architecture": data.get("architecture", {}),
                "references": data.get("references", [])
            }
            print("[MERGE] documentation.json → documentation")
    
    def consolidate_handover(self):
        """Consolidate handover.json"""
        if "handover.json" in self.manifests:
            data = self.manifests["handover.json"]
            self.consolidated["handover"] = {
                "knowledge_transfer": data.get("knowledge_transfer", []),
                "critical_info": data.get("critical_info", []),
                "contacts": data.get("contacts", []),
                "access_credentials": data.get("access_credentials", [])
            }
            print("[MERGE] handover.json → handover")
    
    def consolidate_mtg_collection(self):
        """Consolidate MTG-related JSON files"""
        mtg_data = {}
        
        if "Mtg_Collection_Generator.json" in self.manifests:
            mtg_data["generator_config"] = self.manifests["Mtg_Collection_Generator.json"]
            print("[MERGE] Mtg_Collection_Generator.json → mtg_collection.generator_config")
        
        if "mtg-ocr-project-plan.json" in self.manifests:
            mtg_data["ocr_project_plan"] = self.manifests["mtg-ocr-project-plan.json"]
            print("[MERGE] mtg-ocr-project-plan.json → mtg_collection.ocr_project_plan")
        
        self.consolidated["mtg_collection"] = mtg_data
    
    def consolidate_onboarding(self):
        """Consolidate onboarding.json"""
        if "onboarding.json" in self.manifests:
            data = self.manifests["onboarding.json"]
            self.consolidated["onboarding"] = {
                "setup_steps": data.get("setup_steps", []),
                "prerequisites": data.get("prerequisites", []),
                "first_tasks": data.get("first_tasks", []),
                "resources": data.get("resources", [])
            }
            print("[MERGE] onboarding.json → onboarding")
    
    def add_metadata(self):
        """Add metadata about the consolidation"""
        self.consolidated["metadata"] = {
            "consolidation_date": datetime.now().isoformat(),
            "source_files": list(self.manifests.keys()),
            "total_source_files": len(self.manifests),
            "consolidation_tool": "consolidate_project_manifests.py",
            "version": "2.0"
        }
        print("[MERGE] Added metadata")
    
    def consolidate_all(self) -> Dict[str, Any]:
        """Execute full consolidation"""
        print("\n" + "=" * 70)
        print("CONSOLIDATING MANIFESTS")
        print("=" * 70 + "\n")
        
        self.consolidate_project_description()
        self.consolidate_project_goals()
        self.consolidate_roadmap()
        self.consolidate_directory_structure()
        self.consolidate_documentation()
        self.consolidate_handover()
        self.consolidate_mtg_collection()
        self.consolidate_onboarding()
        self.add_metadata()
        
        print("\n[DONE] Consolidation complete\n")
        return self.consolidated
    
    def save_consolidated(self, output_format: str = "both"):
        """Save consolidated manifest in JSON and/or YAML"""
        output_dir = self.project_root / "000_Project_Manifests"
        output_dir.mkdir(parents=True, exist_ok=True)
        
        print("=" * 70)
        print("SAVING CONSOLIDATED MANIFEST")
        print("=" * 70 + "\n")
        
        # Save as JSON
        if output_format in ["json", "both"]:
            json_path = output_dir / "PROJECT_CONSOLIDATED_MANIFEST.json"
            with open(json_path, 'w', encoding='utf-8') as f:
                json.dump(self.consolidated, f, indent=2, ensure_ascii=False)
            
            size_kb = json_path.stat().st_size / 1024
            print(f"[SAVE] JSON: {json_path} ({size_kb:.1f} KB)")
        
        # Save as YAML
        if output_format in ["yaml", "both"]:
            yaml_path = output_dir / "PROJECT_CONSOLIDATED_MANIFEST.yml"
            with open(yaml_path, 'w', encoding='utf-8') as f:
                yaml.dump(self.consolidated, f, 
                         default_flow_style=False, 
                         allow_unicode=True,
                         sort_keys=False)
            
            size_kb = yaml_path.stat().st_size / 1024
            print(f"[SAVE] YAML: {yaml_path} ({size_kb:.1f} KB)")
        
        print("")
    
    def create_backup(self):
        """Backup original JSON files before consolidation"""
        backup_dir = self.project_root / "000_Project_Manifests" / "backup_originals"
        backup_dir.mkdir(parents=True, exist_ok=True)
        
        print("=" * 70)
        print("CREATING BACKUPS")
        print("=" * 70 + "\n")
        
        for filename in self.manifests.keys():
            source = self.project_root / filename
            dest = backup_dir / filename
            
            try:
                import shutil
                shutil.copy2(source, dest)
                print(f"[BACKUP] {filename} → backup_originals/")
            except Exception as e:
                print(f"[ERROR] Failed to backup {filename}: {str(e)}")
        
        print(f"\n[DONE] Backed up {len(self.manifests)} files\n")
    
    def generate_summary_report(self) -> str:
        """Generate a human-readable summary"""
        lines = []
        lines.append("=" * 70)
        lines.append("CONSOLIDATION SUMMARY REPORT")
        lines.append("=" * 70)
        lines.append("")
        
        # Source files
        lines.append("Source Files:")
        for filename in sorted(self.manifests.keys()):
            lines.append(f"  ✓ {filename}")
        lines.append("")
        
        # Consolidated sections
        lines.append("Consolidated Sections:")
        for section, content in self.consolidated.items():
            if section == "metadata":
                continue
            
            if isinstance(content, dict):
                count = len(content)
            elif isinstance(content, list):
                count = len(content)
            else:
                count = 1
            
            lines.append(f"  • {section}: {count} items")
        lines.append("")
        
        # Roadmap statistics
        if "roadmap" in self.consolidated:
            roadmap = self.consolidated["roadmap"]
            lines.append("Roadmap Statistics:")
            
            if "by_status" in roadmap:
                for status, tasks in roadmap["by_status"].items():
                    lines.append(f"  {status}: {len(tasks)} tasks")
            
            lines.append("")
            
            if "by_priority" in roadmap:
                for priority, tasks in roadmap["by_priority"].items():
                    lines.append(f"  {priority}: {len(tasks)} tasks")
        
        lines.append("")
        lines.append("=" * 70)
        
        return "\n".join(lines)


def main():
    """Main execution"""
    # Determine project root
    if len(sys.argv) > 1:
        project_root = sys.argv[1]
    else:
        project_root = "E:\\NextGen"
    
    print("\n" + "=" * 70)
    print("PROJECT MANIFEST CONSOLIDATION TOOL")
    print("=" * 70)
    print(f"Project Root: {project_root}\n")
    
    # Create consolidator
    consolidator = ManifestConsolidator(project_root)
    
    # Load all JSON files
    consolidator.load_json_files()
    
    if not consolidator.manifests:
        print("[ERROR] No JSON manifests found in project root!")
        sys.exit(1)
    
    # Create backups
    consolidator.create_backup()
    
    # Consolidate
    consolidated = consolidator.consolidate_all()
    
    # Save
    consolidator.save_consolidated(output_format="both")
    
    # Generate and print summary
    summary = consolidator.generate_summary_report()
    print(summary)
    
    # Save summary to file
    summary_path = Path(project_root) / "000_Project_Manifests" / "CONSOLIDATION_SUMMARY.txt"
    with open(summary_path, 'w', encoding='utf-8') as f:
        f.write(summary)
    
    print(f"\n[SAVE] Summary: {summary_path}\n")
    
    print("=" * 70)
    print("CONSOLIDATION COMPLETE!")
    print("=" * 70)
    print("\nNext Steps:")
    print("1. Review: 000_Project_Manifests/PROJECT_CONSOLIDATED_MANIFEST.yml")
    print("2. Backup: 000_Project_Manifests/backup_originals/ (original files)")
    print("3. Optional: Delete original JSON files from project root")
    print("=" * 70 + "\n")


if __name__ == "__main__":
    main()
