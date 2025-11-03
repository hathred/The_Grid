:: WARNING: This is a generated template from setup_env.bat (Source Folder: 990_Project_Automation_Pipeline_bak)
:: Check the token replacements (__XXX__) for correctness.

@echo off
REM ============================================================================
REM Grok: Summarize - Environment Setup Script
REM Author: Hathred88
REM Purpose: Create Python virtual environment and install dependencies
REM ============================================================================

echo ============================================================================
echo GROK: SUMMARIZE - ENVIRONMENT SETUP
echo ============================================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH!
    echo Please install Python 3.9+ from 100_Dependency_Runtime_Archives
    pause
    exit /b 1
)

echo [OK] Python detected
python --version
echo.

REM Set project paths
set "PROJECT_ROOT=__ECOSYSTEM_ROOT__\210_Project_Dev_Tools\Summarize"
set "VENV_PATH=%PROJECT_ROOT%\venv"

REM Create project directory if it doesn't exist
if not exist "%PROJECT_ROOT%" (
    echo [INFO] Creating project directory: %PROJECT_ROOT%
    mkdir "%PROJECT_ROOT%" 2>nul
)

REM Navigate to project directory
cd /d "%PROJECT_ROOT%"
if errorlevel 1 (
    echo [ERROR] Failed to navigate to project directory!
    pause
    exit /b 1
)

echo [INFO] Working directory: %CD%
echo.

REM Check if virtual environment already exists
if exist "%VENV_PATH%\Scripts\activate.bat" (
    echo [WARNING] Virtual environment already exists at: %VENV_PATH%
    echo.
    choice /C YN /M "Do you want to recreate it (this will delete existing environment)"
    if errorlevel 2 (
        echo [INFO] Keeping existing environment
        goto :skip_venv_creation
    )
    echo [INFO] Removing existing environment...
    rmdir /s /q "%VENV_PATH%"
)

REM Create virtual environment
echo [INFO] Creating Python virtual environment...
python -m venv "%VENV_PATH%"
if errorlevel 1 (
    echo [ERROR] Failed to create virtual environment!
    pause
    exit /b 1
)

echo [OK] Virtual environment created
echo.

:skip_venv_creation

REM Activate virtual environment
echo [INFO] Activating virtual environment...
call "%VENV_PATH%\Scripts\activate.bat"
if errorlevel 1 (
    echo [ERROR] Failed to activate virtual environment!
    pause
    exit /b 1
)

echo [OK] Virtual environment activated
echo.

REM Upgrade pip
echo [INFO] Upgrading pip...
python -m pip install --upgrade pip
echo.

REM Check if requirements.txt exists
if not exist "requirements.txt" (
    echo [WARNING] requirements.txt not found in current directory
    echo [INFO] Creating minimal requirements.txt...
    (
        echo # Grok: Summarize - Python Dependencies
        echo PyYAML^>=6.0.3
        echo packaging^>=25.0
    ) > requirements.txt
)

REM Install dependencies
echo [INFO] Installing dependencies from requirements.txt...
pip install -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies!
    echo [INFO] Attempting offline install from 100_Dependency_Runtime_Archives...
    set "DEPS_DIR=__ECOSYSTEM_ROOT__\100_Dependency_Runtime_Archives"
    if exist "%DEPS_DIR%\pyyaml*.whl" (
        pip install --no-index --find-links="%DEPS_DIR%" PyYAML packaging
    ) else (
        echo [ERROR] Offline dependencies not found!
        pause
        exit /b 1
    )
)

echo.
echo [OK] Dependencies installed successfully
echo.

REM Create directory structure
echo [INFO] Creating project directory structure...
if not exist "src" mkdir src
if not exist "tests" mkdir tests
if not exist "output" mkdir output
if not exist "logs" mkdir logs

REM Create __init__.py files for Python packages
type nul > src\__init__.py
type nul > tests\__init__.py

echo [OK] Directory structure created
echo.

REM Display summary
echo ============================================================================
echo SETUP COMPLETE
echo ============================================================================
echo Virtual Environment: %VENV_PATH%
echo Python Version: 
python --version
echo.
echo Installed Packages:
pip list
echo.
echo ============================================================================
echo.
echo NEXT STEPS:
echo 1. Run: 2_run_pipeline_dryrun.bat (test without writing files)
echo 2. Review the logs in: 995_Project_Logs
echo 3. Run: 3_run_pipeline_full.bat (full processing)
echo.
echo To manually activate environment: %VENV_PATH%\Scripts\activate.bat
echo ============================================================================
echo.

pause
