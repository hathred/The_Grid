# Fresh Install: Harvest Dependencies from Manifests
# Run: powershell -EP Bypass -File "E:\NextGen\harvest_deps.ps1"
# Outputs to E:\Codex\Installers\[Dir]\
# Add to top: Skip if file exists
if (Test-Path $targetPath) {
    Write-Host "SKIP (exists): $fileName"
} else {
    Write-Host "DOWNLOAD: $url → $targetPath"
    Invoke-WebRequest -Uri $url -OutFile $targetPath
}
$codexRoot = "E:\Codex\Installers"
$nextGenRoot = "E:\NextGen\Offline_IT_Ecosystem"
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