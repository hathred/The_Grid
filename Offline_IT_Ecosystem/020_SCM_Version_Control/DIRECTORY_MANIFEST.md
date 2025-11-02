# Directory Manifest: 020_SCM_Version_Control

## Purpose
Source Code Management and version control archives. Contains installers, documentation, and configuration for Git, Gitea, and other version control systems essential for offline code collaboration and repository management in the Outranet.

## Key Contents
- `gitea-1.24.6-gogit-windows-4.0-amd64.exe` – Gitea self-hosted Git service
- `Git-2.46.0-64-bit.exe` – Git for Windows 2.46.0
- `Gitlab_install_instructions.txt` – Offline GitLab CE installation guide
- `gitea-1.24.6-darwin-10.12-amd64` – Gitea macOS binary
- `git-config-templates/` – Pre-configured .gitconfig files

## Version
- Gitea: 1.24.6 (2024-10-28)
- Git: 2.46.0 (2024-10-28)
- GitLab CE: 17.3.0 (Reference only)

## Dependencies
- 100_Dependency_Runtime_Archives (Go runtime for Gitea)
- 040_Web_Server_Frontend (Nginx/Apache for Gitea web interface)
- 010_Data_RDBMS_NoSQL (PostgreSQL/SQLite for Gitea backend)

## Deployment Paths
> **The final, ready-to-run location after `deploy_to_output.ps1`**

| Platform       | Path |
|----------------|------|
| **Windows**    | `E:\Deploy\Offline_IT_Ecosystem\020_SCM_Version_Control\` |
| **Linux**      | `/opt/offline-ecosystem/020_SCM_Version_Control/` |
| **macOS**      | `/opt/offline-ecosystem/020_SCM_Version_Control/` |
| **Portable USB**| `X:\Offline_IT_Ecosystem\020_SCM_Version_Control\` |

## Auto-Download Sources
> **(When online)** – URLs used by `deploy_to_output.ps1` or `auto_download.ps1`

- [Gitea Windows](https://dl.gitea.io/gitea/1.24.6/gitea-1.24.6-gogit-windows-4.0-amd64.exe)
- [Git for Windows](https://github.com/git-for-windows/git/releases/download/v2.46.0.windows.1/Git-2.46.0-64-bit.exe)
- [Gitea macOS](https://dl.gitea.io/gitea/1.24.6/gitea-1.24.6-darwin-10.12-amd64)

## Setup Guides (Generated)
> Auto-created by `deploy_to_output.ps1` in this directory:
- `SETUP_WINDOWS.md`
- `SETUP_LINUX.md`
- `SETUP_MACOS.md`

## Notes
- **Air-gapped tested**: Yes (Gitea verified with local PostgreSQL)
- **Backfilled from Codex**: Yes → `E:\Codex\Installers\Git\`
- **Last Updated**: 2025-11-02
- **TODO**: Configure Gitea with offline SSL certificates