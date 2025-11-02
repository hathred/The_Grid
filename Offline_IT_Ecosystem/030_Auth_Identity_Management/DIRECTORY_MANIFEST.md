# Directory Manifest: 030_Auth_Identity_Management

## Purpose
Identity Provider and authentication tools and archives. Contains offline installers and configuration for Keycloak, OpenLDAP, and other identity management systems essential for securing the Outranet services and applications.

## Key Contents
- `keycloak-26.4.2.zip` – Keycloak 26.4.2 identity and access management
- `openldap-2.6.10.tgz` – OpenLDAP 2.6.10 directory service
- `keycloak-themes/` – Custom offline themes and templates
- `ldap-config-samples/` – Pre-configured LDAP schema and configuration files
- `saml-metadata/` – Sample SAML 2.0 metadata for testing

## Version
- Keycloak: 26.4.2 (2024-10-23)
- OpenLDAP: 2.6.10 (2024-10-15)

## Dependencies
- 100_Dependency_Runtime_Archives (Java 17+ for Keycloak)
- 040_Web_Server_Frontend (Reverse proxy configuration)
- 010_Data_RDBMS_NoSQL (PostgreSQL for Keycloak persistence)

## Deployment Paths
> **The final, ready-to-run location after `deploy_to_output.ps1`**

| Platform       | Path |
|----------------|------|
| **Windows**    | `E:\Deploy\Offline_IT_Ecosystem\030_Auth_Identity_Management\` |
| **Linux**      | `/opt/offline-ecosystem/030_Auth_Identity_Management/` |
| **macOS**      | `/opt/offline-ecosystem/030_Auth_Identity_Management/` |
| **Portable USB**| `X:\Offline_IT_Ecosystem\030_Auth_Identity_Management\` |

## Auto-Download Sources
> **(When online)** – URLs used by `deploy_to_output.ps1` or `auto_download.ps1`

- [Keycloak 26.4.2](https://github.com/keycloak/keycloak/releases/download/26.4.2/keycloak-26.4.2.zip)
- [OpenLDAP 2.6.10](https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.6.10.tgz)

## Setup Guides (Generated)
> Auto-created by `deploy_to_output.ps1` in this directory:
- `SETUP_WINDOWS.md`
- `SETUP_LINUX.md`
- `SETUP_MACOS.md`

## Notes
- **Air-gapped tested**: Yes (Keycloak with embedded H2 database)
- **Backfilled from Codex**: Yes → `E:\Codex\Installers\Keycloak\`
- **Last Updated**: 2025-11-02
- **TODO**: Generate offline CA certificates for SAML testing