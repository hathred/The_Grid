# Directory Manifest: 000_Project_Manifests

## Purpose
Core metadata, project manifest files, and overall configuration for the Offline IT Ecosystem. This directory serves as the central governance hub, housing high-level inventories, versioning data, and structural blueprints to ensure discoverability, integrity, and air-gapped compliance across the NextGen project.

## Key Contents
- `manifest.yml` – Comprehensive YAML inventory of the repository, detailing core systems, dependencies, and archival libraries (e.g., system utilities, development environments, creative tools).
- `PROJECT_MANIFEST.yaml` – High-level metadata for sub-projects, including versions, relationships, and governance rules.
- `DML_Specification.md` – Specification for Directory Manifest Language, including minify/structure examples and schema (TODO: TaskList.json ID:3).
- `DEPLOYMENT_CHECKLIST.md` – Final deployment checklist for the ecosystem (TODO: TaskList.json ID:53).
- `Roadmap.json` – Merged project roadmap for future development (DONE: TaskList.json ID:61).

## Version
- manifest.yml: v1.0 (Repository version 1.0.0 per Project_Description.json)
- DML Specification: v0.1 (Draft)
- Last Inventory Scan: 2025-11-02

## Dependencies
- 195_Documentation_Knowledge_Base (For unified docs and knowledge references)
- 990_Project_Automation (Scripts like sort_ecosystem.bat for enforcing structure)
- 995_Project_Logs (For logging changes to manifests)

## Deployment Paths
> **The final, ready-to-run location after `deploy_to_output.ps1`**

| Platform       | Path |
|----------------|------|
| **Windows**    | `E:\Deploy\Offline_IT_Ecosystem\000_Project_Manifests\` |
| **Linux**      | `/opt/offline-ecosystem/000_Project_Manifests/` |
| **macOS**      | `/opt/offline-ecosystem/000_Project_Manifests/` |
| **Portable USB**| `X:\Offline_IT_Ecosystem\000_Project_Manifests\` |

## Auto-Download Sources
> **(When online)** – URLs used by `deploy_to_output.ps1` or `auto_download.ps1`

- [Project Roadmap Updates](https://raw.githubusercontent.com/[your-repo]/main/Roadmap.json)
- [Manifest Schema Reference](https://github.com/opencontainers/image-spec/blob/main/schema-manifest.json)

## Setup Guides (Generated)
> Auto-created by `deploy_to_output.ps1` in this directory:
- `SETUP_WINDOWS.md`
- `SETUP_LINUX.md`
- `SETUP_MACOS.md`

## Notes
- **Air-gapped tested**: Yes (All contents are static YAML/MD files; no external calls)
- **Backfilled from Codex**: No (Pure documentation directory)
- **Last Updated**: 2025-11-02
- **TODO**: TaskList.json IDs: 3, 53 (DML spec, deployment checklist)