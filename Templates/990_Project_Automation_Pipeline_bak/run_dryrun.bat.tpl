:: WARNING: This is a generated template from run_dryrun.bat (Source Folder: 990_Project_Automation_Pipeline_bak)
:: Check the token replacements (__XXX__) for correctness.

@echo off
REM ============================================================================
REM Grok: Summarize - Dry Run Execution Script
REM Author: Hathred88
REM Purpose: Test the pipeline WITHOUT writing any output files
REM ============================================================================

echo ============================================================================
echo GROK: SUMMARIZE - DRY RUN EXECUTION
echo ============================================================================
echo.
echo This will test the pipeline WITHOUT writing any files.
echo Use this to verify configuration and check for errors.
echo.

REM Set project paths
set "PROJECT_ROOT=__ECOSYSTEM_ROOT__\210_Project_Dev_Tools\Summarize"
set "VENV_PATH=%PROJECT_ROOT%\venv"

REM Check if virtual environment exists
if not exist "%VENV_PATH%\Scripts\activate.bat" (
    echo [ERROR] Virtual environment not found!
    echo Please run 1_setup_environment.bat first.
    pause
    exit /b 1
)

REM Navigate to project directory
cd /d "%PROJECT_ROOT%"
if errorlevel 1 (
    echo [ERROR] Failed to navigate to project directory!
    pause
    exit /b 1
)

REM Activate virtual environment
echo [INFO] Activating virtual environment...
call "%VENV_PATH%\Scripts\activate.bat"
if errorlevel 1 (
    echo [ERROR] Failed to activate virtual environment!
    pause
    exit /b 1
)

echo [OK] Environment activated
echo.

REM Check if src files exist
if not exist "src\main_grok.py" (
    echo [ERROR] main_grok.py not found in src\ directory!
    echo Please ensure all Python modules are in place.
    pause
    exit /b 1
)

REM Display configuration
echo ============================================================================
echo CONFIGURATION
echo ============================================================================
echo Project Root: %PROJECT_ROOT%
echo Python: 
python --version
echo.
echo Config File: config.yaml
if exist "config.yaml" (
    echo [OK] Configuration file found
) else (
    echo [WARNING] Configuration file not found, using defaults
)
echo.

REM Prompt for confirmation
echo ============================================================================
echo Ready to start DRY RUN
echo ============================================================================
echo This will:
echo - Scan all files in 200_Content_Data_Source
echo - Test cleaning and encoding logic
echo - Report what WOULD be written (but won't actually write anything)
echo - Generate a log file in 995_Project_Logs
echo.
pause
echo.

REM Execute pipeline in dry-run mode
echo [INFO] Starting pipeline in DRY RUN mode...
echo ============================================================================
echo.

python src\main_grok.py --dry-run

set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo ============================================================================

if %EXIT_CODE% equ 0 (
    echo [SUCCESS] Dry run completed successfully!
    echo.
    echo Check the log file in: __ECOSYSTEM_ROOT__\995_Project_Logs
    echo.
    echo If everything looks good, run: 3_run_pipeline_full.bat
) else (
    echo [ERROR] Dry run failed with exit code: %EXIT_CODE%
    echo.
    echo Check the log file for details.
    echo Common issues:
    echo - Missing dependencies (run 1_setup_environment.bat again)
    echo - Invalid configuration in config.yaml
    echo - Permission issues accessing source files
)

echo.
echo ============================================================================
echo.

pause
