# Directory Manifest: 040_Web_Server_Frontend

## Purpose
Web server installers and core frontend files for hosting static and dynamic web applications within the Outranet. Contains Apache HTTP Server, Nginx, PHP runtimes, and essential frontend frameworks for air-gapped web serving.

## Key Contents
- `httpd-2.4.62-win64-VS17.zip` – Apache HTTP Server 2.4.62
- `nginx-1.26.1.zip` – Nginx 1.26.1 web server
- `php-8.3.11-Win32-vs16-x64.zip` – PHP 8.3.11 runtime
- `frontend_starter_kits/` – Bootstrap, jQuery, and HTML5 templates
- `ssl_certificates/` – Self-signed certificates for HTTPS testing

## Version
- Apache: 2.4.62 (2024-10-29)
- Nginx: 1.26.1 (2024-10-22)
- PHP: 8.3.11 (2024-10-31)

## Dependencies
- 100_Dependency_Runtime_Archives (PHP runtime dependencies)
- 030_Auth_Identity_Management (Authentication integration)
- 050_Network_Core_Services (Load balancing configuration)

## Deployment Paths
> **The final, ready-to-run location after `deploy_to_output.ps1`**

| Platform       | Path |
|----------------|------|
| **Windows**    | `E:\Deploy\Offline_IT_Ecosystem\040_Web_Server_Frontend\` |
| **Linux**      | `/opt/offline-ecosystem/040_Web_Server_Frontend/` |
| **macOS**      | `/opt/offline-ecosystem/040_Web_Server_Frontend/` |
| **Portable USB**| `X:\Offline_IT_Ecosystem\040_Web_Server_Frontend\` |

## Auto-Download Sources
> **(When online)** – URLs used by `deploy_to_output.ps1` or `auto_download.ps1`

- [Apache 2.4.62](https://www.apachelounge.com/download/VS17/binaries/httpd-2.4.62-win64-VS17.zip)
- [Nginx 1.26.1](http://nginx.org/download/nginx-1.26.1.zip)
- [PHP 8.3.11](https://windows.php.net/downloads/releases/php-8.3.11-Win32-vs16-x64.zip)

## Setup Guides (Generated)
> Auto-created by `deploy_to_output.ps1` in this directory:
- `SETUP_WINDOWS.md`
- `SETUP_LINUX.md`
- `SETUP_MACOS.md`

## Notes
- **Air-gapped tested**: Yes (Apache with PHP-CGI)
- **Backfilled from Codex**: Yes → `E:\Codex\Installers\WebServer\`
- **Last Updated**: 2025-11-02
- **TODO**: Configure Nginx reverse proxy for Keycloak integration