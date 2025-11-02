# NextGen Offline IT Ecosystem: Fresh Install Requirements
**Version:** 1.0.0 | **Date:** 2025-11-01 | **Assumes:** Blank E:\NextGen, Windows 10+ | **Air-Gap Post-Install:** YES

## Core Bootstrap (Download Once, Online)
These are the minimal "Gods' hammer" reqs to bootstrap the Installer. Download manually or via script.

| Tool | Version | Download URL | Purpose | Size (Approx) |
|------|---------|--------------|---------|---------------|
| **Python** | 3.12.7 | https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe | DML Pipeline, scripts (e.g., engine.py) | 25 MB |
| **Git CLI** | 2.51.2 | https://github.com/git-for-windows/git/releases/download/v2.51.2.windows.1/Git-2.51.2-64-bit.exe | SCM (020_), repo cloning | 50 MB |

**Install Order:**
1. Run Python installer → Check "Add to PATH".
2. Run Git installer → Default options.
3. Verify: `python --version` + `git --version`.

## Full Dependency Harvest (From Manifests)
Parsed from DIRECTORY_MANIFEST.md files. Run `E:\NextGen\harvest_deps.ps1` (below) to auto-download.

### 000_Project_Manifests
- No binaries (static YAML/MD).

### 010_Data_RDBMS_NoSQL
| Tool | Version | Download URL | Size |
|------|---------|--------------|------|
| PostgreSQL | 16.4 | https://www.enterprisedb.com/downloads/postgres-postgresql-downloads (select Windows x86-64) | 250 MB |
| MongoDB | 8.0.1 | https://www.mongodb.com/try/download/community (Windows MSI) | 300 MB |
| SQLite Tools | 3.45.3 | https://www.sqlite.org/download.html (sqlite-tools-win32-x86-3450300.zip) | 2 MB |
| WAMP | 3.3.4 | https://www.wampserver.com/en/ (WAMP64-3.3.4-64.exe) | 400 MB |

### 020_SCM_Version_Control
| Tool | Version | Download URL | Size |
|------|---------|--------------|------|
| Gitea (Win) | 1.24.6 | https://dl.gitea.io/gitea/1.24.6/gitea-1.24.6-gogit-windows-4.0-amd64.exe | 80 MB |
| Git (Win) | 2.46.0 | https://github.com/git-for-windows/git/releases/download/v2.46.0.windows.1/Git-2.46.0-64-bit.exe | 50 MB |
| Gitea (macOS) | 1.24.6 | https://dl.gitea.io/gitea/1.24.6/gitea-1.24.6-darwin-10.12-amd64 | 80 MB |

**Total Harvest Size:** ~1.5 GB (scalable; add more manifests).

## Post-Harvest Validation
- Run `E:\NextGen\validate_deps.bat` → Check hashes/sizes.
- Air-Gap Seal: Disconnect after Phase 1.

## TODO (TaskList.json Links)
- ID:47 — Integrate deploy.bat.
- Expand for all 000-995 dirs.