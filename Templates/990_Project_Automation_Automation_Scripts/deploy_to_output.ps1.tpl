:: WARNING: This is a generated template from deploy_to_output.ps1 (Source Folder: 990_Project_Automation_Automation_Scripts)
:: Check the token replacements (__XXX__) for correctness.

# __ECOSYSTEM_ROOT__\990_Project_Automation\deploy_to_output.ps1
# PURPOSE: Mirror structure to E:\Deploy, backfill from __OFFLINE_FILES__, generate OS docs

$SourceRoot = "__ECOSYSTEM_ROOT__"
$DeployRoot = "E:\Deploy\Offline_IT_Ecosystem"
$CodexRoot  = "__OFFLINE_FILES__"
$LogFile    = "__ECOSYSTEM_ROOT__\995_Project_Logs\deploy_log.txt"

function Log { param($msg); "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) - $msg" | Out-File -Append -FilePath $LogFile }

Log "DEPLOYMENT STARTED"

# === 1. CREATE DEPLOY STRUCTURE ===
if (Test-Path $DeployRoot) { Remove-Item $DeployRoot -Recurse -Force }
Copy-Item $SourceRoot $DeployRoot -Recurse -Force
Log "Structure mirrored from NextGen to Deploy"

# === 2. BACKFILL FROM CODEX ===
$BackfillMap = @{
    "010_Data_RDBMS_NoSQL" = "__OFFLINE_FILES__\Installers\Databases"
    "020_SCM_Version_Control" = "__OFFLINE_FILES__\Installers\Git"
    "030_Auth_Identity_Management" = "__OFFLINE_FILES__\Installers\Keycloak"
    "200_Content_Data_Source\MTG_Collection\Scryfall" = "__OFFLINE_FILES__\Pages\MTG_Collection\Scryfall"
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