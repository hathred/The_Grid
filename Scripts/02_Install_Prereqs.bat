@echo off
setlocal enableDelayedExpansion

REM =================================================================================
REM Please Review this block and ensure all bugs remained corrected in future iterations.
REM
REM UPDATE: Per user request, the Python check now uses 'python --version' to see if 
REM Python is in the system PATH. If found, installation is skipped. 
REM
REM BUG FIX (Current): Corrected the path concatenation for Python and Chrome 
REM executables by explicitly adding a backslash ('\') after !INSTALL_ROOT!.
REM This fixes the critical issue where, if INSTALL_ROOT was 'E:\NextGen' (without 
REM a trailing slash), the path would incorrectly become 'E:\NextGenPython\python.exe' 
REM instead of 'E:\NextGen\Python\python.exe'.
REM 
REM Please include this block, appended as necessary, to all future iterations. 
REM BUG FIX can be minified to save space.
REM =================================================================================

REM =================================================================================
REM Please document all external scripts used
REM
REM External Scripts:
REM - Winget (for system software installation)
REM
REM Please Persist this block in all future iterations
REM =================================================================================

ECHO.
ECHO =================================================================================
ECHO 2. Prerequisite Software Installation
ECHO =================================================================================
ECHO.

REM --- Python Check and Install (Updated per user request to use 'python --version') ---
:PythonCheck
    CALL :Log "Starting Python Check (python --version)"
    ECHO.
    ECHO --- Python Check and Install ---
    
    REM 1. Check for system-wide Python (user request)
    python --version 2>nul
    IF %ERRORLEVEL% EQU 0 (
        ECHO [SUCCESS] System-wide Python detected in PATH. Skipping local installation.
        CALL :Log "SUCCESS: System-wide Python found. Skipping local install."
        GOTO :ChromeCheck
    )

    ECHO Python not found in system PATH. Checking for local installation...
    
    REM 2. Check for local Python (Expected path is !INSTALL_ROOT!\Python\python.exe)
    REM *** CRITICAL FIX APPLIED: Added '\' after !INSTALL_ROOT! ***
    SET "PYTHON_EXE_PATH=!INSTALL_ROOT!\Python\python.exe"
    ECHO [DEBUG] Expected Local Python path: "!PYTHON_EXE_PATH!"
    
    IF EXIST "!PYTHON_EXE_PATH!" (
        ECHO [SUCCESS] Local Python detected at "!PYTHON_EXE_PATH!". Skipping installation.
        CALL :Log "SUCCESS: Local Python detected at expected path. Skipping install."
        GOTO :ChromeCheck
    )

    ECHO Local Python not detected. Attempting installation via Winget...
    REM *** CRITICAL FIX APPLIED: Added '\' after !INSTALL_ROOT! in log and Winget command ***
    CALL :Log "Installing Python to location: !INSTALL_ROOT!\Python"
    
    REM Note: We are attempting a specific version of Python and specifying the install location.
    winget install --id Python.Python.3.11 --location "!INSTALL_ROOT!\Python" --accept-package-agreements --scope machine
    
    IF %ERRORLEVEL% NEQ 0 (
        ECHO [ERROR] Python installation via Winget failed. Exit code: %ERRORLEVEL%.
        ECHO [ACTION] Please manually install Python 3.11+ to: "!INSTALL_ROOT!\Python"
        CALL :Log "ERROR: Python installation failed (Winget exit code %ERRORLEVEL%)."
    ) ELSE (
        ECHO [SUCCESS] Python installed successfully via Winget.
        CALL :Log "SUCCESS: Python installed via Winget."
    )
    
    :ChromeCheck
    CALL :Log "Starting Chrome Check"
    ECHO.
    ECHO --- Chrome Check and Install ---
    
    REM Expected path is !INSTALL_ROOT!\Chrome\chrome.exe
    REM *** CRITICAL FIX APPLIED: Added '\' after !INSTALL_ROOT! ***
    SET "CHROME_EXE_PATH=!INSTALL_ROOT!\Chrome\chrome.exe"
    ECHO [DEBUG] Expected Chrome path: "!CHROME_EXE_PATH!"
    
    IF EXIST "!CHROME_EXE_PATH!" (
        ECHO [SUCCESS] Chrome detected at "!CHROME_EXE_PATH!". Skipping installation.
        CALL :Log "SUCCESS: Chrome detected at expected path. Skipping install."
        GOTO :InstallSoftwareEnd
    )

    ECHO Chrome not detected. Attempting installation of Google Chrome via Winget...
    REM *** CRITICAL FIX APPLIED: Added '\' after !INSTALL_ROOT! in log and Winget command ***
    CALL :Log "Installing Chrome to location: !INSTALL_ROOT!\Chrome"
    
    winget install --id Google.Chrome --location "!INSTALL_ROOT!\Chrome" --accept-package-agreements
    
    IF %ERRORLEVEL% NEQ 0 (
        ECHO [ERROR] Chrome installation via Winget failed. Exit code: %ERRORLEVEL%.
        ECHO [ACTION] Please manually install Google Chrome to: "!INSTALL_ROOT!\Chrome"
        CALL :Log "ERROR: Chrome installation failed (Winget exit code %ERRORLEVEL%)."
    ) ELSE (
        ECHO [SUCCESS] Google Chrome installed successfully via Winget.
        CALL :Log "SUCCESS: Chrome installed via Winget."
    )

:InstallSoftwareEnd
    ECHO.
    ECHO [INFO] Prerequisite installation step finished.
    CALL :Log "02_Install_Prereqs.bat completed."

    EXIT /B 0

REM --- LOCAL SUBROUTINE DEFINITION (Copy from master for logging) ---
:Log
    REM Simple logging function that prepends a timestamp
    IF NOT DEFINED LOG_FILE GOTO :eof
    ECHO [%%DATE%% %%TIME%%] %%~1 >>"!LOG_FILE!"
    GOTO :eof
