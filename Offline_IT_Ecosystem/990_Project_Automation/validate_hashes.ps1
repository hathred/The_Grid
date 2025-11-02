# =============================================================================
# Hash Verification Script
# Purpose: Validate downloaded files against SHA256 checksums in manifests
# Usage: .\validate_hashes.ps1 -ManifestPath "020_SCM_Version_Control\manifest_schema.yml"
# =============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$ManifestPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$CodexRoot = "E:\Codex\Installers",
    
    [Parameter(Mandatory=$false)]
    [switch]$FixMode = $false,  # Generate missing hashes
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose = $false
)

# Requires PowerShell-Yaml module
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Write-Warning "PowerShell-Yaml module not found. Installing..."
    Install-Module -Name powershell-yaml -Force -Scope CurrentUser
}

Import-Module powershell-yaml

function Get-FileHash-SHA256 {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        return $null
    }
    
    $hash = Get-FileHash -Path $FilePath -Algorithm SHA256
    return $hash.Hash.ToLower()
}

function Validate-ManifestHashes {
    param(
        [string]$ManifestFile,
        [string]$BaseDir
    )
    
    Write-Host "`n============================================================" -ForegroundColor Cyan
    Write-Host "VALIDATING: $ManifestFile" -ForegroundColor Cyan
    Write-Host "============================================================`n" -ForegroundColor Cyan
    
    # Load YAML manifest
    try {
        $manifest = Get-Content $ManifestFile -Raw | ConvertFrom-Yaml
    }
    catch {
        Write-Error "Failed to parse YAML: $ManifestFile"
        return $false
    }
    
    if (-not $manifest.download_urls) {
        Write-Warning "No download_urls section found in manifest"
        return $true
    }
    
    $totalFiles = $manifest.download_urls.Count
    $validFiles = 0
    $invalidFiles = 0
    $missingFiles = 0
    $missingHashes = 0
    
    foreach ($download in $manifest.download_urls) {
        $filename = $download.filename
        $expectedHash = $download.sha256
        $componentDir = Split-Path $ManifestFile -Parent
        $componentName = Split-Path $componentDir -Leaf
        
        # Construct file path
        $filePath = Join-Path $BaseDir $componentName
        $filePath = Join-Path $filePath $filename
        
        Write-Host "[CHECK] $filename" -ForegroundColor Yellow
        
        # Check if file exists
        if (-not (Test-Path $filePath)) {
            Write-Host "  [MISSING] File not found: $filePath" -ForegroundColor Red
            $missingFiles++
            continue
        }
        
        # Check if hash is defined
        if ([string]::IsNullOrWhiteSpace($expectedHash) -or $expectedHash -like "*TODO*" -or $expectedHash -like "*abc123*") {
            if ($FixMode) {
                Write-Host "  [FIX] Generating hash..." -ForegroundColor Magenta
                $actualHash = Get-FileHash-SHA256 -FilePath $filePath
                Write-Host "  [HASH] $actualHash" -ForegroundColor Cyan
                
                # TODO: Update manifest with new hash (requires YAML write-back)
                Write-Host "  [INFO] Add this to manifest: sha256: `"$actualHash`"" -ForegroundColor Green
            }
            else {
                Write-Host "  [NO HASH] sha256 not defined in manifest" -ForegroundColor Yellow
                $missingHashes++
            }
            continue
        }
        
        # Validate hash
        $actualHash = Get-FileHash-SHA256 -FilePath $filePath
        
        if ($actualHash -eq $expectedHash) {
            Write-Host "  [VALID] Hash matches: $actualHash" -ForegroundColor Green
            $validFiles++
        }
        else {
            Write-Host "  [INVALID] Hash mismatch!" -ForegroundColor Red
            Write-Host "    Expected: $expectedHash" -ForegroundColor Red
            Write-Host "    Actual:   $actualHash" -ForegroundColor Red
            $invalidFiles++
        }
        
        if ($Verbose) {
            $fileSize = (Get-Item $filePath).Length / 1MB
            Write-Host "    Size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Gray
        }
    }
    
    # Summary
    Write-Host "`n------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "SUMMARY" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Total Files:    $totalFiles"
    Write-Host "Valid:          $validFiles" -ForegroundColor Green
    Write-Host "Invalid:        $invalidFiles" -ForegroundColor Red
    Write-Host "Missing Files:  $missingFiles" -ForegroundColor Red
    Write-Host "Missing Hashes: $missingHashes" -ForegroundColor Yellow
    Write-Host "============================================================`n" -ForegroundColor Cyan
    
    return ($invalidFiles -eq 0 -and $missingFiles -eq 0)
}

function Scan-AllManifests {
    param([string]$RootDir)
    
    Write-Host "`n============================================================" -ForegroundColor Cyan
    Write-Host "SCANNING FOR MANIFESTS IN: $RootDir" -ForegroundColor Cyan
    Write-Host "============================================================`n" -ForegroundColor Cyan
    
    $manifests = Get-ChildItem -Path $RootDir -Filter "manifest_schema.yml" -Recurse
    
    if ($manifests.Count -eq 0) {
        # Fallback to DIRECTORY_MANIFEST.md
        Write-Warning "No manifest_schema.yml found. Checking for DIRECTORY_MANIFEST.md..."
        $manifests = Get-ChildItem -Path $RootDir -Filter "DIRECTORY_MANIFEST.md" -Recurse
    }
    
    Write-Host "Found $($manifests.Count) manifests`n"
    
    $allValid = $true
    foreach ($manifest in $manifests) {
        $result = Validate-ManifestHashes -ManifestFile $manifest.FullName -BaseDir $CodexRoot
        if (-not $result) {
            $allValid = $false
        }
    }
    
    return $allValid
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

if ($ManifestPath -ne "") {
    # Single manifest validation
    $result = Validate-ManifestHashes -ManifestFile $ManifestPath -BaseDir $CodexRoot
    exit $(if ($result) { 0 } else { 1 })
}
else {
    # Scan all manifests in E:\NextGen\Offline_IT_Ecosystem
    $ecosystemRoot = "E:\NextGen\Offline_IT_Ecosystem"
    
    if (-not (Test-Path $ecosystemRoot)) {
        Write-Error "Ecosystem root not found: $ecosystemRoot"
        exit 1
    }
    
    $result = Scan-AllManifests -RootDir $ecosystemRoot
    
    if ($result) {
        Write-Host "`n[SUCCESS] All hashes validated successfully!" -ForegroundColor Green
        exit 0
    }
    else {
        Write-Host "`n[FAILURE] Some files failed validation" -ForegroundColor Red
        Write-Host "Run with -FixMode to generate missing hashes`n" -ForegroundColor Yellow
        exit 1
    }
}
