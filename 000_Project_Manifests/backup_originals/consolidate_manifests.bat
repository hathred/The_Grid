@echo off
REM ============================================================================
REM Project Manifest Consolidation Wrapper
REM Purpose: Merge all JSON files in project root into unified manifest
REM Usage: consolidate_manifests.bat
REM ============================================================================

echo ============================================================================
echo PROJECT MANIFEST CONSOLIDATION
echo ============================================================================
echo.
echo This will:
echo  1. Load all JSON files from E:\NextGen\
echo  2. Backup originals to 000_Project_Manifests\backup_originals\
echo  3. Merge into PROJECT_CONSOLIDATED_MANIFEST.yml and .json
echo  4. Generate a summary report
echo.
echo Original files will NOT be deleted (you can do that manually later)
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found! Please install Python 3.9+ first.
    pause
    exit /b 1
)

echo [OK] Python detected
python --version
echo.

REM Set project root
set "PROJECT_ROOT=E:\NextGen"

REM Check if project root exists
if not exist "%PROJECT_ROOT%" (
    echo [ERROR] Project root not found: %PROJECT_ROOT%
    pause
    exit /b 1
)

echo [INFO] Project root: %PROJECT_ROOT%
echo.

REM Check for required JSON files
echo [INFO] Checking for JSON manifests...
set "JSON_COUNT=0"
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
        set /a JSON_COUNT+=1
        echo   [FOUND] %%~nxf
    )
)

echo.
echo Found %JSON_COUNT% JSON manifest files
echo.

if %JSON_COUNT% equ 0 (
    echo [ERROR] No JSON manifests found in project root!
    pause
    exit /b 1
)

REM Confirm execution
echo ============================================================================
echo Ready to consolidate
echo ============================================================================
echo.
choice /C YN /M "Do you want to continue"
if errorlevel 2 (
    echo [INFO] Consolidation cancelled by user
    pause
    exit /b 0
)
echo.

REM Check if consolidation script exists
set "SCRIPT_PATH=%PROJECT_ROOT%\consolidate_project_manifests.py"

if not exist "%SCRIPT_PATH%" (
    echo [WARNING] Consolidation script not found at expected location
    echo [INFO] Creating script in current directory...
    
    REM Create script in project root if not exists
    set "SCRIPT_PATH=%PROJECT_ROOT%\consolidate_project_manifests.py"
    
    if not exist "%SCRIPT_PATH%" (
        echo [ERROR] Please place consolidate_project_manifests.py in project root
        pause
        exit /b 1
    )
)

echo [INFO] Using script: %SCRIPT_PATH%
echo.

REM Execute consolidation
echo [INFO] Running consolidation script...
echo ============================================================================
echo.

python "%SCRIPT_PATH%" "%PROJECT_ROOT%"

set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo ============================================================================

if %EXIT_CODE% equ 0 (
    echo [SUCCESS] Consolidation completed!
    echo.
    echo Output files:
    echo   • %PROJECT_ROOT%\000_Project_Manifests\PROJECT_CONSOLIDATED_MANIFEST.yml
    echo   • %PROJECT_ROOT%\000_Project_Manifests\PROJECT_CONSOLIDATED_MANIFEST.json
    echo   • %PROJECT_ROOT%\000_Project_Manifests\CONSOLIDATION_SUMMARY.txt
    echo.
    echo Backups:
    echo   • %PROJECT_ROOT%\000_Project_Manifests\backup_originals\
    echo.
    echo NEXT STEPS:
    echo   1. Review the consolidated manifest
    echo   2. If satisfied, you can delete the original JSON files from project root
    echo   3. Or run: del E:\NextGen\*.json (BE CAREFUL!)
) else (
    echo [ERROR] Consolidation failed with exit code: %EXIT_CODE%
    echo.
    echo Check the output above for error details
)

echo.
echo ============================================================================
echo.

pause
