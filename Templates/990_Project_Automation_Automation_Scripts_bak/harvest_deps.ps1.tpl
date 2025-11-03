:: WARNING: This is a generated template from harvest_deps.ps1 (Source Folder: 990_Project_Automation_Automation_Scripts_bak)
:: Check the token replacements (__XXX__) for correctness.

# Fresh Install: Harvest Dependencies from Manifests
# Run: powershell -EP Bypass -File "__INSTALL_ROOT__\harvest_deps.ps1"
# Outputs to __OFFLINE_FILES__\Installers\[Dir]\
# Add to top: Skip if file exists
if (Test-Path $targetPath) {
    Write-Host "SKIP (exists): $fileName"
} else {
    Write-Host "DOWNLOAD: $url → $targetPath"
    Invoke-WebRequest -Uri $url -OutFile $targetPath
}
$codexRoot = "__OFFLINE_FILES__\Installers"
$nextGenRoot = "__ECOSYSTEM_ROOT__"
New-Item -ItemType Directory -Force -Path $codexRoot | Out-Null

# Parse manifests & download (example for 010 & 020; extend via loop)
Get-ChildItem -Path $nextGenRoot -Directory -Filter "[0-9][0-9][0-9]_*" | ForEach-Object {
    $dir = $_.Name
    $manifest = Join-Path $_.FullName "DIRECTORY_MANIFEST.md"
    if (Test-Path $manifest) {
        $content = Get-Content $manifest -Raw
        # Scrape URLs (simple regex; enhance with YAML if needed)
        $urls = [regex]::Matches($content, 'https?://[^\s<>"]+') | ForEach-Object { $_.Value }
        
        $targetDir = Join-Path $codexRoot $dir
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        
        $urls | ForEach-Object {
            $url = $_
            $fileName = Split-Path $url -Leaf
            $targetPath = Join-Path $targetDir $fileName
            if (-not (Test-Path $targetPath)) {
                Write-Host "Downloading: $url → $targetPath"
                Invoke-WebRequest -Uri $url -OutFile $targetPath
            }
        }
    }
}

Write-Host "Harvest complete. Codex stocked. Ready for deploy_codex.bat."