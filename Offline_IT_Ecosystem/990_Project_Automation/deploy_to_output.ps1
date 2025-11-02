# E:\NextGen\Offline_IT_Ecosystem\990_Project_Automation\deploy_to_output.ps1
# PURPOSE: Mirror structure to E:\Deploy, backfill from E:\Codex, generate OS docs

$SourceRoot = "E:\NextGen\Offline_IT_Ecosystem"
$DeployRoot = "E:\Deploy\Offline_IT_Ecosystem"
$CodexRoot  = "E:\Codex"
$LogFile    = "E:\NextGen\Offline_IT_Ecosystem\995_Project_Logs\deploy_log.txt"

function Log { param($msg); "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) - $msg" | Out-File -Append -FilePath $LogFile }

Log "DEPLOYMENT STARTED"

# === 1. CREATE DEPLOY STRUCTURE ===
if (Test-Path $DeployRoot) { Remove-Item $DeployRoot -Recurse -Force }
Copy-Item $SourceRoot $DeployRoot -Recurse -Force
Log "Structure mirrored from NextGen to Deploy"

# === 2. BACKFILL FROM CODEX ===
$BackfillMap = @{
    "010_Data_RDBMS_NoSQL" = "E:\Codex\Installers\Databases"
    "020_SCM_Version_Control" = "E:\Codex\Installers\Git"
    "030_Auth_Identity_Management" = "E:\Codex\Installers\Keycloak"
    "200_Content_Data_Source\MTG_Collection\Scryfall" = "E:\Codex\Pages\MTG_Collection\Scryfall"
    # Add more as needed
}

foreach ($dir in $BackfillMap.Keys) {
    $src = $BackfillMap[$dir]
    $dst = "$DeployRoot\$dir"
    if (Test-Path $src) {
        Copy-Item "$src\*" $dst -Recurse -Force
        Log "Backfilled: $dir ← $src"
    }
}

# === 3. GENERATE OS-SPECIFIC SETUP GUIDES ===
$Dirs = Get-ChildItem $DeployRoot -Directory | Where-Object { $_.Name -match '^\d{3}_' }

foreach ($Dir in $Dirs) {
    $manifest = "$($Dir.FullName)\DIRECTORY_MANIFEST.md"
    if (-not (Test-Path $manifest)) { continue }

    $content = Get-Content $manifest -Raw
    $purpose = ($content -split "`n" | Where-Object { $_ -match '## Purpose' }) -replace '## Purpose\s*', ''

    foreach ($os in @("WINDOWS", "LINUX", "MACOS")) {
        $guide = "$($Dir.FullName)\SETUP_$os.md"
        $template = @"
# Setup: $os

## Purpose
$purpose

## Prerequisites
- [ ] OS: $os
- [ ] Admin/root access
- [ ] 2GB+ free space

## Installation
1. Locate installer in this directory
2. Run as administrator (Windows) or `sudo` (Linux/macOS)
3. Follow wizard / use default paths

## Verification
```bash
# Example command
version --check