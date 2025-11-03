# config.ps1 (Executed by the Batch script)

# --- Debloating (Example) ---
# Remove specific pre-installed apps
$AppsToUninstall = @(
    "Microsoft.BingNews",
    "Microsoft.ZuneVideo",
    "Microsoft.XboxApp"
)
ForEach ($App in $AppsToUninstall) {
    Write-Host "Removing $App..."
    Get-AppxPackage -Name $App | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# --- System Settings (Example) ---
# Set power plan to High Performance
powercfg /s 8c5e7fdc-cc2c-4167-831e-a9e8a2e76cc3

# Disable Fast Startup (often causes issues with dual-boot/updates)
powercfg /h off