# E:\NextGen\Offline_IT_Ecosystem\990_Project_Automation\generate_manifests.ps1
# PURPOSE: Enforces DIRECTORY_MANIFEST.md using external template.
# RUN: powershell -EP Bypass -File "E:\NextGen\Offline_IT_Ecosystem\990_Project_Automation\generate_manifests.ps1"

# === CONFIG ===
$Root = "E:\NextGen\Offline_IT_Ecosystem"
$TemplateFile = "$Root\990_Project_Automation\TEMPLATE_DIRECTORY_MANIFEST.md"
$Pattern = "^\d{3}_.*"

# === VALIDATE TEMPLATE ===
if (-not (Test-Path $TemplateFile)) {
    Write-Error "TEMPLATE NOT FOUND: $TemplateFile"
    Write-Host "Create it first with the standard template."
    exit 1
}

$Template = Get-Content $TemplateFile -Raw
if ([string]::IsNullOrWhiteSpace($Template)) {
    Write-Error "TEMPLATE IS EMPTY: $TemplateFile"
    exit 1
}

# === FIND TARGET DIRS ===
$Dirs = Get-ChildItem $Root -Directory | Where-Object { $_.Name -match $Pattern }

foreach ($Dir in $Dirs) {
    $ManifestPath = Join-Path $Dir.FullName "DIRECTORY_MANIFEST.md"

    # === SKIP IF EXISTS (Safe Rerun) ===
    if (Test-Path $ManifestPath) {
        Write-Host "SKIP (Exists): $ManifestPath" -ForegroundColor Yellow
        continue
    }

    # === INJECT DIR NAME INTO TEMPLATE ===
    $Content = $Template -replace '\[DIR_NAME\]', $Dir.Name

    # Optional: Auto-fill Purpose from folder name
    $Purpose = ($Dir.Name -replace '^\d{3}_', '') -replace '_', ' '
    $Content = $Content -replace '\[AUTO_PURPOSE\]', $Purpose

    # Optional: Auto-fill Date
    $Content = $Content -replace '\[TODAY\]', (Get-Date -Format "yyyy-MM-dd")

    # === WRITE MANIFEST ===
    Set-Content -Path $ManifestPath -Value $Content -Encoding UTF8
    Write-Host "CREATED: $ManifestPath" -ForegroundColor Green
}

Write-Host "`nManifest generation complete. Ready for manual curation." -ForegroundColor Cyan