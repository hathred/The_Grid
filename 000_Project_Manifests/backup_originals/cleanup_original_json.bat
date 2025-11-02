@echo off
REM ============================================================================
REM Original JSON Cleanup Script
REM Purpose: Safely remove original JSON files after consolidation verification
REM Usage: cleanup_original_jsons.bat
REM ============================================================================

echo ============================================================================
echo ORIGINAL JSON FILES CLEANUP
echo ============================================================================
echo.
echo [WARNING] This will DELETE the following files from E:\NextGen\:
echo.

set "PROJECT_ROOT=E:\NextGen"
set "FILE_COUNT=0"

REM List files to be deleted
for %%f in (
    "%PROJECT_ROOT%\Directory_manifest.json"
    "%PROJECT_ROOT%\documentation.json"
    "%PROJECT_ROOT%\handover.json"
    "%PROJECT_ROOT%\Mtg_Collection_Generator.json"
    "%PROJECT_ROOT%\mtg-ocr-project-plan.json"
    "%PROJECT_ROOT%\onboarding.json"
    "%PROJECT_ROOT%\Project_Description.json"
    "%PROJECT_ROOT%\project_file_structure_manifest.json"
    "%PROJECT_ROOT%\Project_Goal.json"
    "%PROJECT_ROOT%\Roadmap.json"
) do (
    if exist "%%f" (
        set /a FILE_COUNT+=1
        echo   [DELETE] %%~nxf
    )
)

echo.
echo Total files to delete: %FILE_COUNT%
echo.

if %FILE_COUNT% equ 0 (
    echo [INFO] No original JSON files found. Already cleaned up?
    pause
    exit /b 0
)

REM Verify backup exists
set "BACKUP_DIR=%PROJECT_ROOT%\000_Project_Manifests\backup_originals"

if not exist "%BACKUP_DIR%" (
    echo [ERROR] Backup directory not found!
    echo [ERROR] Please run consolidate_manifests.bat first to create backups
    pause
    exit /b 1
)

echo [OK] Backup verified at: %BACKUP_DIR%
echo.

REM Verify consolidated manifest exists
set "CONSOLIDATED=%PROJECT_ROOT%\000_Project_Manifests\PROJECT_CONSOLIDATED_MANIFEST.yml"

if not exist "%CONSOLIDATED%" (
    echo [ERROR] Consolidated manifest not found!
    echo [ERROR] Please run consolidate_manifests.bat first
    pause
    exit /b 1
)

echo [OK] Consolidated manifest verified
echo.

REM Safety prompt
echo ============================================================================
echo SAFETY CHECK
echo ============================================================================
echo.
echo Before proceeding, please confirm you have:
echo   1. Reviewed the consolidated manifest
echo   2. Verified all important information is preserved
echo   3. Confirmed backups exist in backup_originals\
echo.
echo This action CANNOT be easily undone (use backup_originals\ to restore)
echo.

choice /C YN /M "Are you SURE you want to delete these files"
if errorlevel 2 (
    echo [INFO] Cleanup cancelled by user
    pause
    exit /b 0
)
echo.

REM Final confirmation
echo [FINAL WARNING] Last chance to cancel!
choice /C YN /M "Proceed with deletion"
if errorlevel 2 (
    echo [INFO] Cleanup cancelled by user
    pause
    exit /b 0
)
echo.

REM Delete files
echo [INFO] Deleting original JSON files...
echo ============================================================================
echo.

set "DELETED=0"
set "FAILED=0"

for %%f in (
    "%PROJECT_ROOT%\Directory_manifest.json"
    "%PROJECT_ROOT%\documentation.json"
    "%PROJECT_ROOT%\handover.json"
    "%PROJECT_ROOT%\Mtg_Collection_Generator.json"
    "%PROJECT_ROOT%\mtg-ocr-project-plan.json"
    "%PROJECT_ROOT%\onboarding.json"
    "%PROJECT_ROOT%\Project_Description.json"
    "%PROJECT_ROOT%\project_file_structure_manifest.json"
    "%PROJECT_ROOT%\Project_Goal.json"
    "%PROJECT_ROOT%\Roadmap.json"
) do (
    if exist "%%f" (
        del "%%f" 2>nul
        if exist "%%f" (
            echo [FAILED] %%~nxf
            set /a FAILED+=1
        ) else (
            echo [DELETED] %%~nxf
            set /a DELETED+=1
        )
    )
)

echo.
echo ============================================================================
echo CLEANUP SUMMARY
echo ============================================================================
echo Deleted: %DELETED% files
echo Failed:  %FAILED% files
echo.

if %FAILED% gtr 0 (
    echo [WARNING] Some files could not be deleted
    echo Check if they are in use by another program
) else (
    echo [SUCCESS] All original JSON files cleaned up!
)

echo.
echo Backups remain at: %BACKUP_DIR%
echo Consolidated manifest: %CONSOLIDATED%
echo.
echo ============================================================================
echo.

pause
