@echo off
setlocal EnableDelayedExpansion
title NextGen Installer

REM =================================================================================
REM Please document all external scripts used and CALLed
REM
REM CALLed Scripts:
REM - Scripts\01_Setup_System.bat
REM - Scripts\02_Install_Prereqs.bat
REM - Scripts\03_Generate_Configs.py (Executed directly by python.exe)
REM - Scripts\yaml_reader.py
REM - Scripts\template_gen.py
REM
REM Please Persist this block in all future iterations
REM =================================================================================

echo =================================================================================
echo Starting NextGen Environment Installer
echo =================================================================================
echo.

REM --- Define Core Paths ---
set "INSTALLER_ROOT=%~dp0"
set "LOG_DIR=%INSTALLER_ROOT%Logs"
set "LOG_FILE=%LOG_DIR%\install_debug.log"
set "SCRIPTS_DIR=%INSTALLER_ROOT%Scripts"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo [DEBUG] Installer Root Path (INSTALLER_ROOT): %INSTALLER_ROOT%
echo [DEBUG] Log File Location (LOG_FILE): %LOG_FILE%
echo [DEBUG] Scripts Directory (SCRIPTS_DIR): %SCRIPTS_DIR%
echo.

set "CONFIG_FILE=%INSTALLER_ROOT%config.txt"

echo Reading configuration from "%CONFIG_FILE%"...
if not exist "%CONFIG_FILE%" (
    echo ERROR: Configuration file not found. Please run initial setup.
    goto :end
)

echo Resolving final runtime paths...

for /f "usebackq tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
    set "%%A=%%B"
)

if not "%INSTALL_ROOT:~-1%"=="\" set "INSTALL_ROOT=%INSTALL_ROOT%\"
if not "%OFFLINE_FILES:~-1%"=="\" set "OFFLINE_FILES=%OFFLINE_FILES%\"
if not "%LOG_DIR:~-1%"=="\" set "LOG_DIR=%LOG_DIR%\"

echo INSTALL_ROOT resolved to: "%INSTALL_ROOT%"
echo OFFLINE_FILES resolved to: "%OFFLINE_FILES%"
echo LOG_DIR resolved to: "%LOG_DIR%"
echo.

REM -----------------------------------------------------------------
REM 1. System Setup Stage
REM -----------------------------------------------------------------
echo --- Running Setup Stage ---
call "%SCRIPTS_DIR%\01_Setup_System.bat" "%INSTALL_ROOT%" "%OFFLINE_FILES%" "%LOG_DIR%"
if errorlevel 1 (
    echo [ERROR] 01_Setup_System.bat failed.
    goto :end
)
echo.

REM -----------------------------------------------------------------
REM 2. Install Prerequisites Stage
REM -----------------------------------------------------------------
echo --- Running Prerequisite Installation ---
call "%SCRIPTS_DIR%\02_Install_Prereqs.bat" "%INSTALL_ROOT%" "%OFFLINE_FILES%" "%LOG_DIR%"
if errorlevel 1 (
    echo [ERROR] 02_Install_Prereqs.bat failed.
    goto :end
)
echo.

REM -----------------------------------------------------------------
REM 3. Generate Configs Stage (Python)
REM -----------------------------------------------------------------
echo --- Generating Configuration Files ---
set "PYTHON_SCRIPTS_DIR=%SCRIPTS_DIR%"
set "TEMPLATE_DIR=%INSTALL_ROOT%Templates"
set "TARGET_ECOSYSTEM_ROOT=%INSTALL_ROOT%Offline_IT_Ecosystem\990_Project_Automation"

where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found in PATH. Please install Python and re-run installer.
    goto :end
)

python "%SCRIPTS_DIR%\03_Generate_Configs.py" ^
    "%INSTALL_ROOT%" "%OFFLINE_FILES%" "%LOG_DIR%" ^
    "%PYTHON_SCRIPTS_DIR%" "%TEMPLATE_DIR%" "%TARGET_ECOSYSTEM_ROOT%"

if errorlevel 1 (
    echo [ERROR] Config generation failed (03_Generate_Configs.py).
    goto :end
)

echo.
echo All installation stages completed successfully.
echo.
pause

:end
echo Exiting installer.
endlocal
exit /b
