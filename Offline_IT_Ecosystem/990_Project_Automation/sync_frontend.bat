@echo off
REM ============================================================================
REM Grok: Summarize - Frontend Sync Script
REM Author: Hathred88
REM Purpose: Copy generated .dml.b64 files to the SPA data directory
REM ============================================================================

echo ============================================================================
echo GROK: SUMMARIZE - SYNC TO FRONTEND
echo ============================================================================
echo.

REM Set paths
set "SOURCE_DIR=E:\NextGen\Offline_IT_Ecosystem\210_Project_Dev_Tools\Summarize\output"
set "TARGET_DIR=E:\NextGen\Offline_IT_Ecosystem\040_Web_Server_Frontend\data"

REM Check if source directory exists
if not exist "%SOURCE_DIR%" (
    echo [ERROR] Source directory not found: %SOURCE_DIR%
    echo Please run 3_run_pipeline_full.bat first to generate DML files.
    pause
    exit /b 1
)

REM Check if source has files
dir /b "%SOURCE_DIR%\*.dml.b64" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No .dml.b64 files found in source directory!
    echo Please run 3_run_pipeline_full.bat first.
    pause
    exit /b 1
)

REM Create target directory if it doesn't exist
if not exist "%TARGET_DIR%" (
    echo [INFO] Creating target directory: %TARGET_DIR%
    mkdir "%TARGET_DIR%" 2>nul
)

REM Display summary
echo Source: %SOURCE_DIR%
echo Target: %TARGET_DIR%
echo.

REM Count files
for /f %%A in ('dir /b /s "%SOURCE_DIR%\*.dml.b64" ^| find /c /v ""') do set FILE_COUNT=%%A

echo Found %FILE_COUNT% DML files to sync
echo.

REM Calculate total size
set "TOTAL_SIZE=0"
for /r "%SOURCE_DIR%" %%F in (*.dml.b64) do (
    set /a "TOTAL_SIZE+=%%~zF"
)
set /a "TOTAL_SIZE_MB=%TOTAL_SIZE% / 1048576"

echo Total size: %TOTAL_SIZE_MB% MB
echo.

REM Prompt for confirmation
choice /C YN /M "Do you want to sync these files to the frontend"
if errorlevel 2 (
    echo [INFO] Sync cancelled by user
    pause
    exit /b 0
)
echo.

REM Perform sync
echo [INFO] Syncing files...
echo ============================================================================
echo.

REM Use robocopy for efficient sync (preserves directory structure)
robocopy "%SOURCE_DIR%" "%TARGET_DIR%" *.dml.b64 /E /MT:8 /R:3 /W:5 /NP /NDL /NC /NS

if errorlevel 8 (
    echo [ERROR] Sync failed with errors!
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo [SUCCESS] Sync completed!
echo ============================================================================
echo.
echo Files have been copied to: %TARGET_DIR%
echo.
echo NEXT STEPS:
echo 1. Start your web server (Apache/NGINX from 040_Web_Server_Frontend)
echo 2. Open the SPA in a browser
echo 3. Verify that data loads correctly
echo.

REM Optional: Create a manifest of synced files
echo [INFO] Creating sync manifest...
set "MANIFEST_FILE=%TARGET_DIR%\sync_manifest.txt"
(
    echo Grok: Summarize - Frontend Data Sync Manifest
    echo Generated: %DATE% %TIME%
    echo.
    echo Total Files: %FILE_COUNT%
    echo Total Size: %TOTAL_SIZE_MB% MB
    echo.
    echo Files:
    dir /b /s "%TARGET_DIR%\*.dml.b64"
) > "%MANIFEST_FILE%"

echo [OK] Manifest created: %MANIFEST_FILE%
echo.
echo ============================================================================
echo.

pause
