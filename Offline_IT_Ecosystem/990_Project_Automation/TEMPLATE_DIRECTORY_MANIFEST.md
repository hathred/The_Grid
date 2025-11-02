# Directory Manifest: [DIR_NAME]

## Purpose
[AUTO_PURPOSE]

## Key Contents
- `file_or_folder/` – purpose
- `tool-vX.Y.Z.exe` – source

## Version
[Latest tool versions, ISO dates, etc.]

## Dependencies
- [100_Dependency_Runtime_Archives]
- [990_Project_Automation]

## Deployment Paths
> **The final, ready-to-run location after `deploy_to_output.ps1`**

| Platform       | Path |
|----------------|------|
| **Windows**    | `E:\Deploy\Offline_IT_Ecosystem\[DIR_NAME]\` |
| **Linux**      | `/opt/offline-ecosystem/[DIR_NAME]/` |
| **macOS**      | `/opt/offline-ecosystem/[DIR_NAME]/` |
| **Portable USB**| `X:\Offline_IT_Ecosystem\[DIR_NAME]\` |

## Auto-Download Sources
> **(When online)** – URLs used by `deploy_to_output.ps1` or `auto_download.ps1`

- [Example: Scryfall Oracle Cards](https://api.scryfall.com/bulk-data/oracle-cards)
- [Example: Kali Linux ISO](https://cdimage.kali.org/kali-2025.3/kali-linux-2025.3-installer-amd64.iso)

## Setup Guides (Generated)
> Auto-created by `deploy_to_output.ps1` in this directory:
- `SETUP_WINDOWS.md`
- `SETUP_LINUX.md`
- `SETUP_MACOS.md`

## Notes
- **Air-gapped tested**: Yes/No
- **Backfilled from Codex**: Yes/No → `E:\Codex\Installers\...`
- **Last Updated**: [TODAY]
- **TODO**: [Link to TaskList.json ID if applicable]