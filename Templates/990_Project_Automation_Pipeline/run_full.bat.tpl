:: WARNING: This is a generated template from run_full.bat (Source Folder: 990_Project_Automation_Pipeline)
:: Check the token replacements (__XXX__) for correctness.

@echo off
REM ============================================================================
REM Grok: Summarize - Full Pipeline Execution Script
REM Author: Hathred88
REM Purpose: Run the complete DML generation pipeline
REM ============================================================================

echo ============================================================================
echo GROK: SUMMARIZE - FULL PIPELINE EXECUTION
echo ============================================================================
echo.
echo [WARNING] This will process ALL files and write output to:
echo __ECOSYSTEM_ROOT__\210_Project_Dev_Tools\Summarize\output
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
echo Source: __ECOSYSTEM_ROOT__\200_Content_Data_Source
echo Output: __ECOSYSTEM_ROOT__\210_Project_Dev_Tools\Summarize\output
echo.

REM Check if force flag should be used
echo ============================================================================
echo EXECUTION MODE
echo ============================================================================
echo.
echo Choose execution mode:
echo [1] Normal - Only process files that have changed
echo [2] Force  - Reprocess ALL files regardless of timestamps
echo.
choice /C 12 /N /M "Select mode (1 or 2): "
set "MODE=%ERRORLEVEL%"
echo.

set "FORCE_FLAG="
if "%MODE%"=="2" (
    set "FORCE_FLAG=--force"
    echo [INFO] Force mode selected - will reprocess all files
) else (
    echo [INFO] Normal mode selected - will skip up-to-date files
)
echo.

REM Final confirmation
echo ============================================================================
echo FINAL CONFIRMATION
echo ============================================================================
echo About to start FULL PIPELINE execution.
echo.
echo This may take several minutes depending on data size.
echo.
choice /C YN /M "Do you want to continue"
if errorlevel 2 (
    echo [INFO] Execution cancelled by user
    pause
    exit /b 0
)
echo.

REM Execute pipeline
echo [INFO] Starting pipeline execution...
echo ============================================================================
echo.

REM Record start time
set "START_TIME=%TIME%"

REM Run the pipeline
python src\main_grok.py %FORCE_FLAG%

set "EXIT_CODE=%ERRORLEVEL%"
set "END_TIME=%TIME%"

echo.
echo ============================================================================

if %EXIT_CODE% equ 0 (
    echo [SUCCESS] Pipeline completed successfully!
    echo.
    echo Start Time: %START_TIME%
    echo End Time:   %END_TIME%
    echo.
    echo Output files written to:
    echo %PROJECT_ROOT%\output
    echo.
    echo Log file created in:
    echo __ECOSYSTEM_ROOT__\995_Project_Logs
    echo.
    echo NEXT STEP: Run 4_sync_to_frontend.bat to copy files to the SPA
) else (
    echo [ERROR] Pipeline failed with exit code: %EXIT_CODE%
    echo.
    echo Start Time: %START_TIME%
    echo End Time:   %END_TIME%
    echo.
    echo Check the log file for details.
)

echo.
echo ============================================================================
echo.

pause
