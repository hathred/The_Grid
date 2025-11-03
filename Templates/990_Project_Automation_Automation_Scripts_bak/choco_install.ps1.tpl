:: WARNING: This is a generated template from choco_install.ps1 (Source Folder: 990_Project_Automation_Automation_Scripts_bak)
:: Check the token replacements (__XXX__) for correctness.

# =============================================================================
# Chocolatey Automation Script
# Purpose: Auto-install Windows tools from manifest chocolatey sections
# Usage: .\choco_install.ps1 [-ComponentID "020"] [-DryRun]
# =============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$ComponentID = "",
    
    [Parameter(Mandatory=$false)]
    [string]$EcosystemRoot = "__ECOSYSTEM_ROOT__",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false  # Reinstall even if already installed
)

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Error "This script must be run as Administrator!"
    Write-Host "Right-click PowerShell and select 'Run as Administrator'`n" -ForegroundColor Yellow
    exit 1
}

# Requires PowerShell-Yaml
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Write-Warning "Installing PowerShell-Yaml module..."
    Install-Module -Name powershell-yaml -Force -Scope CurrentUser
}

Import-Module powershell-yaml

# Check if Chocolatey is installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "`n[SETUP] Chocolatey not found. Installing..." -ForegroundColor Yellow
    
    if ($DryRun) {
        Write-Host "[DRY RUN] Would install Chocolatey" -ForegroundColor Cyan
    }
    else {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Verify installation
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Host "[OK] Chocolatey installed successfully`n" -ForegroundColor Green
        }
        else {
            Write-Error "Chocolatey installation failed!"
            exit 1
        }
    }
}
else {
    Write-Host "[OK] Chocolatey is already installed" -ForegroundColor Green
    choco --version
    Write-Host ""
}

# Global stats
$script:installed = 0
$script:skipped = 0
$script:failed = 0

function Install-ChocoPackage {
    param(
        [string]$PackageName,
        [string]$Version = "",
        [string]$Source = "",
        [bool]$DryRun = $false,
        [bool]$ForceInstall = $false
    )
    
    # Check if already installed
    $isInstalled = choco list --local-only $PackageName --exact | Select-String -Pattern "^$PackageName "
    
    if ($isInstalled -and -not $ForceInstall) {
        Write-Host "  [SKIP] Already installed: $PackageName" -ForegroundColor Yellow
        $script:skipped++
        return $true
    }
    
    # Build install command
    $chocoCmd = "choco install -y $PackageName"
    
    if ($Version -ne "") {
        $chocoCmd += " --version=$Version"
    }
    
    if ($Source -ne "") {
        $chocoCmd += " --source=$Source"
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would execute: $chocoCmd" -ForegroundColor Cyan
        return $true
    }
    
    Write-Host "  [INSTALL] $PackageName" -ForegroundColor Green
    
    try {
        Invoke-Expression $chocoCmd
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Installed: $PackageName" -ForegroundColor Green
            $script:installed++
            return $true
        }
        else {
            Write-Host "  [ERROR] Installation failed with exit code: $LASTEXITCODE" -ForegroundColor Red
            $script:failed++
            return $false
        }
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
        [bool]$ForceInstall = $false
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
    
    # Check for chocolatey section
    if (-not $manifest.chocolatey) {
        Write-Warning "No chocolatey section found in manifest"
        return
    }
    
    # Install each package
    foreach ($pkg in $manifest.chocolatey) {
        $pkgName = $pkg.package
        $pkgVersion = if ($pkg.version) { $pkg.version } else { "" }
        $pkgSource = if ($pkg.source) { $pkg.source } else { "" }
        
        Install-ChocoPackage -PackageName $pkgName -Version $pkgVersion `
                             -Source $pkgSource -DryRun $DryRun `
                             -ForceInstall $ForceInstall
    }
}

function Scan-Manifests {
    param(
        [string]$RootDir,
        [string]$FilterComponentID = "",
        [bool]$DryRun = $false,
        [bool]$ForceInstall = $false
    )
    
    Write-Host "`n============================================================" -ForegroundColor Cyan
    Write-Host "SCANNING: $RootDir" -ForegroundColor Cyan
    Write-Host "============================================================`n" -ForegroundColor Cyan
    
    # Find all manifest_schema.yml files
    $manifests = Get-ChildItem -Path $RootDir -Filter "manifest_schema.yml" -Recurse
    
    if ($manifests.Count -eq 0) {
        Write-Warning "No manifest_schema.yml files found!"
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
        Process-Manifest -ManifestPath $manifest.FullName -DryRun $DryRun -ForceInstall $ForceInstall
    }
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "CHOCOLATEY AUTOMATION SCRIPT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Ecosystem Root: $EcosystemRoot"
Write-Host "Dry Run:        $DryRun"
Write-Host "Force:          $Force"
Write-Host "============================================================`n" -ForegroundColor Cyan

if (-not (Test-Path $EcosystemRoot)) {
    Write-Error "Ecosystem root not found: $EcosystemRoot"
    exit 1
}

# Scan and process
Scan-Manifests -RootDir $EcosystemRoot -FilterComponentID $ComponentID `
               -DryRun $DryRun -ForceInstall $Force

# Print summary
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "INSTALLATION SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Installed: $script:installed packages" -ForegroundColor Green
Write-Host "Skipped:   $script:skipped packages" -ForegroundColor Yellow
Write-Host "Failed:    $script:failed packages" -ForegroundColor Red
Write-Host "============================================================`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "[DRY RUN] No packages were actually installed" -ForegroundColor Cyan
    Write-Host "Run without -DryRun to execute installations`n" -ForegroundColor Yellow
}

exit $(if ($script:failed -eq 0) { 0 } else { 1 })
