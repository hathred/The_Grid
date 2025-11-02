# Setup: WINDOWS

## Purpose
Core metadata, project manifest files, and overall configuration for the Offline IT Ecosystem.

## Prerequisites
- [ ] Windows 10/11 (64-bit)
- [ ] Admin access
- [ ] 100MB free space
- [ ] PowerShell 5.1+

## Installation
1. No installer — this is a **documentation directory**
2. Open `E:\Deploy\Offline_IT_Ecosystem\000_Project_Manifests\`
3. Review `manifest.yml` in Notepad++ or VS Code

## Verification
```powershell
# Check manifest exists
Test-Path "E:\Deploy\Offline_IT_Ecosystem\000_Project_Manifests\manifest.yml"
# Should return: True