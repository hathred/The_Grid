# JSON Manifest Consolidation Guide

**Project:** The Grid - Offline IT Ecosystem  
**Purpose:** Merge 10+ JSON files in project root into unified manifest  
**Date:** 2025-11-02

---

## 🎯 Overview

### Current State (Before)
```
E:\NextGen\
├── Directory_manifest.json
├── documentation.json
├── handover.json
├── Mtg_Collection_Generator.json
├── mtg-ocr-project-plan.json
├── onboarding.json
├── Project_Description.json
├── project_file_structure_manifest.json
├── Project_Goal.json
├── Roadmap.json
└── ... (other files)
```

**Problem:** Multiple overlapping JSON files causing:
- Information fragmentation
- Redundancy
- Difficult to maintain
- No single source of truth

### Target State (After)
```
E:\NextGen\
├── 000_Project_Manifests\
│   ├── PROJECT_CONSOLIDATED_MANIFEST.yml  ← Single source of truth
│   ├── PROJECT_CONSOLIDATED_MANIFEST.json  ← Same data, JSON format
│   ├── CONSOLIDATION_SUMMARY.txt
│   ├── manifest_schema.yml  ← Component template
│   └── backup_originals\
│       ├── Directory_manifest.json
│       ├── documentation.json
│       └── ... (all originals backed up)
└── ... (original JSONs removed from root)
```

**Benefits:**
- ✅ Single unified manifest
- ✅ Original data preserved in backups
- ✅ Organized by logical sections
- ✅ Available in both YAML (human-readable) and JSON (programmatic)

---

## 📋 Pre-Flight Checklist

Before running consolidation, ensure:

- [ ] Python 3.9+ installed and in PATH
- [ ] PyYAML module installed (`pip install pyyaml`)
- [ ] All JSON files exist in `E:\NextGen\`
- [ ] You have write permissions to `000_Project_Manifests\`
- [ ] Git repository is committed (optional but recommended)

### Quick Python Check
```batch
python --version
python -c "import yaml; print('PyYAML OK')"
```

If PyYAML missing:
```batch
pip install pyyaml
```

---

## 🚀 Step-by-Step Execution

### **Step 1: Place Scripts in Project Root**

Copy these 3 files to `E:\NextGen\`:

1. `consolidate_project_manifests.py` (Python script - main logic)
2. `consolidate_manifests.bat` (Batch wrapper - easy execution)
3. `cleanup_original_jsons.bat` (Cleanup script - run AFTER verification)

**File locations:**
```
E:\NextGen\
├── consolidate_project_manifests.py
├── consolidate_manifests.bat
└── cleanup_original_jsons.bat
```

---

### **Step 2: Run Consolidation**

Double-click or run from command line:
```batch
E:\NextGen\consolidate_manifests.bat
```

**What happens:**
1. Checks for Python and PyYAML
2. Discovers all JSON files in project root
3. Shows you what will be processed
4. Asks for confirmation
5. Creates backups in `000_Project_Manifests\backup_originals\`
6. Merges all data into unified structure
7. Saves as `.yml` and `.json`
8. Generates summary report

**Expected Output:**
```
============================================================================
PROJECT MANIFEST CONSOLIDATION TOOL
============================================================================
Project Root: E:\NextGen

============================================================================
LOADING JSON MANIFESTS
============================================================================
[LOAD] Directory_manifest.json (12.3 KB)
[LOAD] documentation.json (8.5 KB)
[LOAD] handover.json (4.2 KB)
[LOAD] Mtg_Collection_Generator.json (15.1 KB)
[LOAD] mtg-ocr-project-plan.json (22.7 KB)
[LOAD] onboarding.json (6.8 KB)
[LOAD] Project_Description.json (9.4 KB)
[LOAD] project_file_structure_manifest.json (45.2 KB)
[LOAD] Project_Goal.json (5.3 KB)
[LOAD] Roadmap.json (38.9 KB)

Loaded 10 manifests

============================================================================
CREATING BACKUPS
============================================================================
[BACKUP] Directory_manifest.json → backup_originals/
[BACKUP] documentation.json → backup_originals/
...
[DONE] Backed up 10 files

============================================================================
CONSOLIDATING MANIFESTS
============================================================================
[MERGE] Project_Description.json → description
[MERGE] Project_Goal.json → goals
[MERGE] Roadmap.json → roadmap (organized by status/priority/domain/phase)
[MERGE] Directory_manifest.json → structure.directory_manifest
[MERGE] project_file_structure_manifest.json → structure.file_structure
[MERGE] documentation.json → documentation
[MERGE] handover.json → handover
[MERGE] Mtg_Collection_Generator.json → mtg_collection.generator_config
[MERGE] mtg-ocr-project-plan.json → mtg_collection.ocr_project_plan
[MERGE] onboarding.json → onboarding
[MERGE] Added metadata

[DONE] Consolidation complete

============================================================================
SAVING CONSOLIDATED MANIFEST
============================================================================
[SAVE] JSON: E:\NextGen\000_Project_Manifests\PROJECT_CONSOLIDATED_MANIFEST.json (168.5 KB)
[SAVE] YAML: E:\NextGen\000_Project_Manifests\PROJECT_CONSOLIDATED_MANIFEST.yml (172.3 KB)

============================================================================
CONSOLIDATION SUMMARY REPORT
============================================================================

Source Files:
  ✓ Directory_manifest.json
  ✓ Roadmap.json
  ✓ documentation.json
  ... (all 10 files)

Consolidated Sections:
  • description: 5 items
  • goals: 4 items
  • roadmap: 4 items
  • structure: 2 items
  • documentation: 4 items
  • handover: 4 items
  • mtg_collection: 2 items
  • onboarding: 4 items

Roadmap Statistics:
  TODO: 42 tasks
  IN_PROGRESS: 3 tasks
  DONE: 10 tasks
  
  CRITICAL: 5 tasks
  HIGH: 18 tasks
  MEDIUM: 20 tasks
  LOW: 12 tasks

============================================================================
[SAVE] Summary: E:\NextGen\000_Project_Manifests\CONSOLIDATION_SUMMARY.txt

============================================================================
CONSOLIDATION COMPLETE!
============================================================================

Next Steps:
1. Review: 000_Project_Manifests/PROJECT_CONSOLIDATED_MANIFEST.yml
2. Backup: 000_Project_Manifests/backup_originals/ (original files)
3. Optional: Delete original JSON files from project root
============================================================================
```

---

### **Step 3: Review Consolidated Manifest**

Open in your favorite editor:
```
E:\NextGen\000_Project_Manifests\PROJECT_CONSOLIDATED_MANIFEST.yml
```

**Structure Overview:**
```yaml
manifest_version: "2.0"
project_name: "The Grid - Offline IT Ecosystem"
created: "2025-11-02T14:30:00"

description:
  overview: "..."
  purpose: "..."
  scope: "..."
  target_audience: [...]
  key_features: [...]

goals:
  primary: "..."
  secondary: [...]
  success_criteria: [...]
  milestones: [...]

roadmap:
  by_status:
    TODO: [...]
    IN_PROGRESS: [...]
    DONE: [...]
  by_priority:
    CRITICAL: [...]
    HIGH: [...]
    MEDIUM: [...]
    LOW: [...]
  by_domain:
    "Project Governance & Automation": [...]
    "Data Processing": [...]
    # ... etc
  by_phase:
    "Setup & Manifest": [...]
    "Core Development": [...]
    # ... etc

structure:
  directory_manifest: {...}
  file_structure: {...}

documentation:
  guides: [...]
  api_docs: [...]
  architecture: {...}
  references: [...]

handover:
  knowledge_transfer: [...]
  critical_info: [...]
  contacts: [...]
  access_credentials: [...]

mtg_collection:
  generator_config: {...}
  ocr_project_plan: {...}

onboarding:
  setup_steps: [...]
  prerequisites: [...]
  first_tasks: [...]
  resources: [...]

metadata:
  consolidation_date: "2025-11-02T14:30:00"
  source_files: [...]
  total_source_files: 10
```

---

### **Step 4: Verify Data Integrity**

**Check key information is present:**

1. **Roadmap Tasks:**
   ```yaml
   roadmap:
     by_status:
       DONE: 10 tasks  # Should match your actual DONE count
       TODO: 42 tasks
   ```

2. **Project Goals:**
   ```yaml
   goals:
     primary: "A self-contained, air-gapped, refreshable..."
   ```

3. **MTG Collection Config:**
   ```yaml
   mtg_collection:
     generator_config:
       # Check your MTG generator settings
   ```

4. **Documentation Links:**
   ```yaml
   documentation:
     guides:
       - name: "..."
         path: "..."
   ```

**Verification Checklist:**
- [ ] Roadmap task count matches (check by_status totals)
- [ ] Project description is complete
- [ ] MTG collection settings preserved
- [ ] File structure manifest intact
- [ ] Documentation references present
- [ ] Handover information included
- [ ] Onboarding steps listed

---

### **Step 5: Cleanup Original Files (Optional)**

⚠️ **ONLY after verifying consolidated manifest is correct!**

Run cleanup script:
```batch
E:\NextGen\cleanup_original_jsons.bat
```

**Safety Features:**
- Verifies backups exist before deleting
- Verifies consolidated manifest exists
- Requires two confirmations
- Shows exactly what will be deleted

**What gets deleted:**
```
E:\NextGen\Directory_manifest.json         → DELETED
E:\NextGen\documentation.json              → DELETED
E:\NextGen\handover.json                   → DELETED
E:\NextGen\Mtg_Collection_Generator.json   → DELETED
E:\NextGen\mtg-ocr-project-plan.json       → DELETED
E:\NextGen\onboarding.json                 → DELETED
E:\NextGen\Project_Description.json        → DELETED
E:\NextGen\project_file_structure_manifest.json → DELETED
E:\NextGen\Project_Goal.json               → DELETED
E:\NextGen\Roadmap.json                    → DELETED
```

**What remains:**
```
E:\NextGen\000_Project_Manifests\
├── PROJECT_CONSOLIDATED_MANIFEST.yml  ← Your new single source of truth
├── PROJECT_CONSOLIDATED_MANIFEST.json
├── CONSOLIDATION_SUMMARY.txt
└── backup_originals\
    └── (all originals safely backed up)
```

---

## 🔍 Understanding the Consolidated Structure

### **Section Breakdown**

#### 1. **description** - Project Overview
- `overview`: High-level project summary
- `purpose`: Why this project exists
- `scope`: What's included/excluded
- `target_audience`: Who this is for
- `key_features`: Main capabilities

#### 2. **goals** - Strategic Objectives
- `primary`: Main project goal
- `secondary`: Supporting goals
- `success_criteria`: How to measure success
- `milestones`: Key checkpoints

#### 3. **roadmap** - Development Plan
Organized **4 ways** for easy filtering:

**By Status:**
- `TODO`: Not started (highest priority first)
- `IN_PROGRESS`: Currently being worked on
- `DONE`: Completed tasks

**By Priority:**
- `CRITICAL`: Must have for MVP
- `HIGH`: Important for full functionality
- `MEDIUM`: Nice to have
- `LOW`: Future enhancements

**By Domain:**
- Groups tasks by functional area (e.g., "Data Processing", "Frontend Integration")

**By Phase:**
- Groups tasks by development phase (e.g., "Setup & Manifest", "Core Development")

#### 4. **structure** - File Organization
- `directory_manifest`: Directory structure documentation
- `file_structure`: Detailed file tree with metadata

#### 5. **documentation** - Reference Materials
- `guides`: How-to documents
- `api_docs`: API references
- `architecture`: System design docs
- `references`: External resources

#### 6. **handover** - Knowledge Transfer
- `knowledge_transfer`: Key concepts to understand
- `critical_info`: Must-know information
- `contacts`: People to reach out to
- `access_credentials`: System access info

#### 7. **mtg_collection** - MTG-Specific Data
- `generator_config`: MTG collection generator settings
- `ocr_project_plan`: OCR project roadmap

#### 8. **onboarding** - Getting Started
- `setup_steps`: How to set up the environment
- `prerequisites`: What you need before starting
- `first_tasks`: Where to begin
- `resources`: Learning materials

#### 9. **metadata** - Consolidation Info
- `consolidation_date`: When this was created
- `source_files`: Which files were merged
- `total_source_files`: Count of source files

---

## 🛠️ Using the Consolidated Manifest

### **Quick Queries (YAML)**

**Find all HIGH priority TODO tasks:**
```yaml
roadmap:
  by_priority:
    HIGH:
      - {id: 1, description: "...", status: "TODO"}
      - {id: 5, description: "...", status: "TODO"}
```

**Check what's DONE:**
```yaml
roadmap:
  by_status:
    DONE:
      - {id: 48, description: "Ensure raw Scryfall API data..."}
      - {id: 49, description: "Verify structure of text archives..."}
```

**View by domain:**
```yaml
roadmap:
  by_domain:
    "Project Governance & Automation":
      - {id: 1, phase: "Setup & Manifest", ...}
      - {id: 2, phase: "Setup & Manifest", ...}
```

### **Programmatic Access (Python)**

```python
import yaml

# Load consolidated manifest
with open('000_Project_Manifests/PROJECT_CONSOLIDATED_MANIFEST.yml') as f:
    manifest = yaml.safe_load(f)

# Get all TODO tasks
todo_tasks = manifest['roadmap']['by_status']['TODO']
print(f"TODO tasks: {len(todo_tasks)}")

# Get HIGH priority items
high_priority = manifest['roadmap']['by_priority']['HIGH']
for task in high_priority:
    print(f"[{task['id']}] {task['description']}")

# Get project description
print(manifest['description']['overview'])
```

### **DML Pipeline Integration**

Update your DML pipeline to use consolidated manifest:

```python
# In grok_main.py or similar
def load_project_manifest():
    manifest_path = Path('000_Project_Manifests/PROJECT_CONSOLIDATED_MANIFEST.yml')
    with open(manifest_path) as f:
        return yaml.safe_load(f)

manifest = load_project_manifest()

# Use roadmap for processing priority
for task in manifest['roadmap']['by_priority']['HIGH']:
    if task['status'] == 'TODO':
        # Process high priority task
        pass
```

---

## 🔄 Updating the Consolidated Manifest

### **Manual Updates**

Edit the YAML file directly:
```yaml
# Add a new goal
goals:
  secondary:
    - "New goal here"

# Mark a task as DONE
roadmap:
  by_status:
    DONE:
      - id: 55
        description: "..."
        status: "DONE"  # Changed from TODO
```

### **Re-Consolidation**

If you need to add new source JSON files later:

1. Place new JSON in `E:\NextGen\`
2. Update `consolidate_project_manifests.py` to include new file
3. Run consolidation again (will merge with existing)

### **Version Control**

Recommended Git workflow:
```bash
git add 000_Project_Manifests/PROJECT_CONSOLIDATED_MANIFEST.yml
git commit -m "docs: Update consolidated manifest with new roadmap items"
git push
```

---

## 🐛 Troubleshooting

### **Issue: PyYAML not found**
```
[ERROR] ModuleNotFoundError: No module named 'yaml'
```

**Solution:**
```batch
pip install pyyaml
# Or if in virtual environment:
venv\Scripts\pip install pyyaml
```

### **Issue: Permission denied**
```
[ERROR] PermissionError: [Errno 13] Permission denied: '000_Project_Manifests'
```

**Solution:**
- Run as Administrator
- Or check file/folder is not open in another program

### **Issue: JSON parsing error**
```
[ERROR] json.decoder.JSONDecodeError: Expecting value: line 1 column 1
```

**Solution:**
- Check if JSON file is corrupted
- Validate JSON at https://jsonlint.com/
- Check file encoding (should be UTF-8)

### **Issue: Some data missing after consolidation**
**Solution:**
1. Check `backup_originals/` for original files
2. Review `CONSOLIDATION_SUMMARY.txt` for what was merged
3. Manually add missing data to consolidated YAML
4. Re-run consolidation if needed

---

## 📊 Expected Results

### **File Size Comparison**

| File Type | Before (Total) | After (Consolidated) | Change |
|-----------|---------------|---------------------|--------|
| JSON files | ~170 KB | ~169 KB (.json) | -1% |
| YAML files | N/A | ~172 KB (.yml) | +1% |
| **Total** | ~170 KB | ~341 KB (both formats) | +101% |

*Note: YAML is slightly larger than JSON due to human-readable formatting, but both formats contain identical data*

### **Maintenance Reduction**

| Task | Before | After | Time Saved |
|------|--------|-------|------------|
| Find all TODO tasks | Check 3+ files | Check 1 section | 70% |
| Update project goal | Edit multiple files | Edit 1 file | 80% |
| Review roadmap | Parse Roadmap.json | View organized YAML | 60% |
| Onboard new dev | Share 10+ files | Share 1 file | 90% |

---

## ✅ Success Criteria

Your consolidation is successful when:

- [x] All 10 JSON files backed up to `backup_originals/`
- [x] `PROJECT_CONSOLIDATED_MANIFEST.yml` created
- [x] `PROJECT_CONSOLIDATED_MANIFEST.json` created
- [x] All roadmap tasks present (check totals)
- [x] Project description intact
- [x] MTG collection config preserved
- [x] Documentation references included
- [x] No data loss verified by spot-checking key information

---

## 🎯 Next Steps After Consolidation

1. **Update GitHub README:**
   ```markdown
   ## Project Manifests
   
   All project documentation is consolidated in:
   - `000_Project_Manifests/PROJECT_CONSOLIDATED_MANIFEST.yml`
   
   Legacy manifests backed up in `backup_originals/`
   ```

2. **Update Scripts to Use Consolidated Manifest:**
   - Modify `grok_main.py` to read from consolidated manifest
   - Update roadmap processing to use new structure
   - Point documentation references to new location

3. **Git Commit:**
   ```bash
   git add 000_Project_Manifests/PROJECT_CONSOLIDATED_MANIFEST.yml
   git add 000_Project_Manifests/backup_originals/
   git rm *.json  # Remove original JSON files
   git commit -m "feat: Consolidate project manifests into single YAML"
   git push
   ```

4. **Continue with HIGH Priority Tasks:**
   - Return to YAML manifest migration for components
   - Implement hash verification
   - Set up Ansible for remote deployment

---

## 📞 Support

If you encounter issues:
1. Check `CONSOLIDATION_SUMMARY.txt` for details
2. Review `backup_originals/` for original data
3. Restore from backups if needed: `copy backup_originals\*.json E:\NextGen\`
4. Report issues on GitHub with error logs

---

**You're ready to consolidate! 🚀**

Run `consolidate_manifests.bat` when ready.
