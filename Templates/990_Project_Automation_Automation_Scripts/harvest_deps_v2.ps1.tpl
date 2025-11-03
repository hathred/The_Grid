:: WARNING: This is a generated template from harvest_deps_v2.ps1 (Source Folder: 990_Project_Automation_Automation_Scripts)
:: Check the token replacements (__XXX__) for correctness.

# =============================================================================
# Dependency Harvester v2.0 (YAML-Based)
# Purpose: Download installers from manifest_schema.yml files
# Usage: .\harvest_deps_v2.ps1 [-ComponentID "020"] [-VerifyHash] [-DryRun]
# =============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$ComponentID = "",  # e.g., "020" for SCM
    
    [Parameter(Mandatory=$false)]
    [string]$EcosystemRoot = "__ECOSYSTEM_ROOT__",
    
    [Parameter(Mandatory=$false)]
    [string]$CodexRoot = "__OFFLINE_FILES__\Installers",
    
    [Parameter(Mandatory=$false)]
    [switch]$VerifyHash = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false  # Re-download even if exists
)

# Requires PowerShell-Yaml
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Write-Warning "Installing PowerShell-Yaml module..."
    Install-Module -Name powershell-yaml -Force -Scope CurrentUser
}

Import-Module powershell-yaml

# Global stats
$script:downloaded = 0
$script:skipped = 0
$script:failed = 0
$script:totalSize = 0

function Download-File {
    param(
        [string]$Url,
        [string]$DestPath,
        [string]$ExpectedHash = "",
        [bool]$DryRun = $false,
        [bool]$ForceDownload = $false
    )
    
    $filename = Split-Path $DestPath -Leaf
    
    # Check if already exists
    if ((Test-Path $DestPath) -and -not $ForceDownload) {
        Write-Host "  [SKIP] Already exists: $filename" -ForegroundColor Yellow
        $script:skipped++
        return $true
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would download: $Url" -ForegroundColor Cyan
        Write-Host "            Destination: $DestPath" -ForegroundColor Cyan
        return $true
    }
    
    Write-Host "  [DOWNLOAD] $filename" -ForegroundColor Green
    Write-Host "             from: $Url" -ForegroundColor Gray
    
    try {
        # Ensure directory exists
        $destDir = Split-Path $DestPath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        # Download with progress bar
        $ProgressPreference = 'Continue'
        Invoke-WebRequest -Uri $Url -OutFile $DestPath -UseBasicParsing
        
        $fileSize = (Get-Item $DestPath).Length / 1MB
        Write-Host "  [OK] Downloaded: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
        
        $script:downloaded++
        $script:totalSize += $fileSize
        
        # Verify hash if provided
        if ($VerifyHash -and -not [string]::IsNullOrWhiteSpace($ExpectedHash)) {
            $actualHash = (Get-FileHash -Path $DestPath -Algorithm SHA256).Hash.ToLower()
            
            if ($actualHash -eq $ExpectedHash.ToLower()) {
                Write-Host "  [HASH OK] $actualHash" -ForegroundColor Green
            }
            else {
                Write-Host "  [HASH FAIL] Expected: $ExpectedHash" -ForegroundColor Red
                Write-Host "              Actual:   $actualHash" -ForegroundColor Red
                Remove-Item $DestPath -Force
                $script:failed++
                return $false
            }
        }
        
        return $true
    }
    catch {
        Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        $script:failed++
        return $false
    }
}

function Process-Manifest {
    param(
        [string]$ManifestPath,
        [bool]$DryRun = $false,
        [bool]$ForceDownload = $false
    )
    
    Write-Host "`n============================================================" -ForegroundColor Cyan
    Write-Host "PROCESSING: $ManifestPath" -ForegroundColor Cyan
    Write-Host "============================================================`n" -ForegroundColor Cyan
    
    # Load YAML
    try {
        $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Yaml
    }
    catch {
        Write-Error "Failed to parse YAML: $ManifestPath"
        return
    }
    
    # Extract component info
    $componentID = $manifest.component_id
    $componentName = $manifest.component_name
    
    Write-Host "Component: [$componentID] $componentName`n" -ForegroundColor Yellow
    
    # Check for download_urls section
    if (-not $manifest.download_urls) {
        Write-Warning "No download_urls section found in manifest"
        return
    }
    
    # Create component directory in Codex
    $componentCodexDir = Join-Path $CodexRoot "${componentID}_${componentName}"
    
    if (-not $DryRun -and -not (Test-Path $componentCodexDir)) {
        Write-Host "Creating directory: $componentCodexDir" -ForegroundColor Gray
        New-Item -ItemType Directory -Path $componentCodexDir -Force | Out-Null
    }
    
    # Download each file
    foreach ($download in $manifest.download_urls) {
        $url = $download.url
        $filename = $download.filename
        $sha256 = $download.sha256
        
        $destPath = Join-Path $componentCodexDir $filename
        
        Download-File -Url $url -DestPath $destPath -ExpectedHash $sha256 `
                      -DryRun $DryRun -ForceDownload $ForceDownload
    }
}

function Scan-Manifests {
    param(
        [string]$RootDir,
        [string]$FilterComponentID = "",
        [bool]$DryRun = $false,
        [bool]$ForceDownload = $false
    )
    
    Write-Host "`n============================================================" -ForegroundColor Cyan
    Write-Host "SCANNING: $RootDir" -ForegroundColor Cyan
    Write-Host "============================================================`n" -ForegroundColor Cyan
    
    # Find all manifest_schema.yml files
    $manifests = Get-ChildItem -Path $RootDir -Filter "manifest_schema.yml" -Recurse
    
    if ($manifests.Count -eq 0) {
        Write-Warning "No manifest_schema.yml files found!"
        Write-Host "Tip: Convert DIRECTORY_MANIFEST.md to manifest_schema.yml format`n" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Found $($manifests.Count) manifests`n"
    
    # Filter by component ID if specified
    if ($FilterComponentID -ne "") {
        $manifests = $manifests | Where-Object {
            $content = Get-Content $_.FullName -Raw | ConvertFrom-Yaml
            $content.component_id -eq $FilterComponentID
        }
        Write-Host "Filtered to $($manifests.Count) manifests matching ID: $FilterComponentID`n"
    }
    
    # Process each manifest
    foreach ($manifest in $manifests) {
        Process-Manifest -ManifestPath $manifest.FullName -DryRun $DryRun -ForceDownload $ForceDownload
    }
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "DEPENDENCY HARVESTER v2.0" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Ecosystem Root: $EcosystemRoot"
Write-Host "Codex Root:     $CodexRoot"
Write-Host "Verify Hash:    $VerifyHash"
Write-Host "Dry Run:        $DryRun"
Write-Host "Force:          $Force"
Write-Host "============================================================`n" -ForegroundColor Cyan

if (-not (Test-Path $EcosystemRoot)) {
    Write-Error "Ecosystem root not found: $EcosystemRoot"
    exit 1
}

# Create Codex root if needed
if (-not $DryRun -and -not (Test-Path $CodexRoot)) {
    Write-Host "Creating Codex root: $CodexRoot`n" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $CodexRoot -Force | Out-Null
}

# Scan and process
Scan-Manifests -RootDir $EcosystemRoot -FilterComponentID $ComponentID `
               -DryRun $DryRun -ForceDownload $Force

# Print summary
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "HARVEST SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Downloaded: $script:downloaded files" -ForegroundColor Green
Write-Host "Skipped:    $script:skipped files" -ForegroundColor Yellow
Write-Host "Failed:     $script:failed files" -ForegroundColor Red
Write-Host "Total Size: $([math]::Round($script:totalSize, 2)) MB"
Write-Host "============================================================`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "[DRY RUN] No files were actually downloaded" -ForegroundColor Cyan
    Write-Host "Run without -DryRun to execute downloads`n" -ForegroundColor Yellow
}

exit $(if ($script:failed -eq 0) { 0 } else { 1 })
