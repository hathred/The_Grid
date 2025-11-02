# Directory Manifest: 010_Data_RDBMS_NoSQL

## Purpose
Database installers and data system tools for relational (SQL) and non-relational (NoSQL) database systems. Contains offline installers, configuration templates, and documentation for PostgreSQL, MongoDB, SQLite, and other database engines essential for the air-gapped Outranet.

## Key Contents
- `postgresql-16.4-1-windows-x64.exe` – PostgreSQL 16.4 Windows installer
- `mongo-community-8.0.1-win64.msi` – MongoDB Community Server 8.0.1
- `sqlite-tools-win32-x86-3450300.zip` – SQLite command-line tools
- `db_setup_templates/` – Configuration templates and initialization scripts
- `WAMP64-3.3.4-64.exe` – WAMP server stack (Apache + MySQL + PHP)

## Version
- PostgreSQL: 16.4 (2024-10-31)
- MongoDB: 8.0.1 (2024-10-15)
- SQLite: 3.45.3 (2024-10-30)
- WAMP: 3.3.4 (2024-09-20)

## Dependencies
- 100_Dependency_Runtime_Archives (Python, Node.js for database drivers)
- 040_Web_Server_Frontend (Apache for WAMP stack)
- 070_DevOps_CI_CD (Database migration tools)

## Deployment Paths
> **The final, ready-to-run location after `deploy_to_output.ps1`**

| Platform       | Path |
|----------------|------|
| **Windows**    | `E:\Deploy\Offline_IT_Ecosystem\010_Data_RDBMS_NoSQL\` |
| **Linux**      | `/opt/offline-ecosystem/010_Data_RDBMS_NoSQL/` |
| **macOS**      | `/opt/offline-ecosystem/010_Data_RDBMS_NoSQL/` |
| **Portable USB**| `X:\Offline_IT_Ecosystem\010_Data_RDBMS_NoSQL\` |

## Auto-Download Sources
> **(When online)** – URLs used by `deploy_to_output.ps1` or `auto_download.ps1`

- [PostgreSQL Windows](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)
- [MongoDB Community](https://www.mongodb.com/try/download/community)
- [SQLite Tools](https://www.sqlite.org/download.html)
- [WAMP Server](https://www.wampserver.com/en/)

## Setup Guides (Generated)
> Auto-created by `deploy_to_output.ps1` in this directory:
- `SETUP_WINDOWS.md`
- `SETUP_LINUX.md`
- `SETUP_MACOS.md`

## Notes
- **Air-gapped tested**: Yes (All installers verified offline)
- **Backfilled from Codex**: Yes → `E:\Codex\Installers\Databases\`
- **Last Updated**: 2025-11-02
- **TODO**: Test database connectivity between PostgreSQL and WAMP stack