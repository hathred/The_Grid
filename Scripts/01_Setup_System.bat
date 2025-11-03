@echo off
REM =================================================================================
REM 01_Setup_System.bat - Creates the core directory structure and sets up environment
REM This script is CALLed from 00_Install_Master.bat and includes its own subroutines.
REM =================================================================================
REM =================================================================================
REM Please Review this block and ensure all bugs remained corrected in furture iterations.
REM 
REM Please include this block, appended as necessary, to all future iterations. 
REM BUG FIX can be minified to save space.
REM =================================================================================

REM =================================================================================
REM Please document all external scripts used
REM
REM Please Persist this block in all future iterations
REM =================================================================================

setlocal enableDelayedExpansion
ECHO.
ECHO =================================================================================
ECHO 1. System Setup and Core Directory Creation
ECHO =================================================================================
ECHO.

REM --- A. LOCAL SUBROUTINE DEFINITION ---
REM This is a local copy of :Log, which is necessary because subroutines are not 
REM inherited when using 'CALL' to execute a separate batch file.
:Log
    REM Simple logging function that prepends a timestamp
    IF NOT DEFINED LOG_FILE GOTO :eof
    ECHO [%DATE% %TIME%] %~1 >>"!LOG_FILE!"
    GOTO :eof
REM ----------------------------------------

CALL :Log "Starting 01_Setup_System.bat execution (Self-contained version)"

REM --- B. Sanity Check: Mandatory Variables ---
ECHO [DEBUG] Verifying environment variables passed from master script...
IF NOT DEFINED INSTALL_ROOT (
    ECHO [FATAL ERROR] Environment variable INSTALL_ROOT is missing. Cannot proceed.
    CALL :Log "FATAL: INSTALL_ROOT missing in 01_Setup_System.bat"
    EXIT /B 1
)
IF NOT DEFINED LOG_FILE (
    ECHO [FATAL ERROR] Environment variable LOG_FILE is missing. Cannot proceed.
    EXIT /B 1
)

ECHO [DEBUG] INSTALL_ROOT: "!INSTALL_ROOT!"
ECHO [DEBUG] LOG_FILE: "!LOG_FILE!"

REM --- C. Target Directory List Definition (Safe Iteration) ---
CALL :Log "Defining required core directories."
ECHO [INFO] Defining directory structure...

REM Define directories as separate lines within a string, and use FOR /F to parse them safely.
SET "TARGET_DIR_LIST=Python,Chrome,Data,Templates,Offline_IT_Ecosystem,Offline_IT_Ecosystem\010_Data_RDBMS_NoSQL,Offline_IT_Ecosystem\990_Project_Automation,Offline_IT_Ecosystem\995_Project_Logs"

REM --- D. Core Directory Creation Loop ---
CALL :Log "Starting core directory creation loop."
SET "ERROR_FLAG=0"

REM Iterate through the comma-separated list of directories
FOR %%D IN (!TARGET_DIR_LIST!) DO (
    SET "CURRENT_PATH=!INSTALL_ROOT!%%D"
    ECHO [DEBUG] Checking/creating directory: !CURRENT_PATH!
    
    REM Check if the path exists. Use quotes for paths with spaces (though not in this case)
    IF NOT EXIST "!CURRENT_PATH!\" (
        ECHO [ACTION] Creating missing directory: !CURRENT_PATH!
        MD "!CURRENT_PATH!" 2>nul
        
        IF EXIST "!CURRENT_PATH!\" (
            ECHO [SUCCESS] Directory created: !CURRENT_PATH!
            CALL :Log "SUCCESS: Directory created: !CURRENT_PATH!"
        ) ELSE (
            ECHO [ERROR] Failed to create directory: !CURRENT_PATH! - Check permissions or path length.
            CALL :Log "ERROR: Failed to create directory: !CURRENT_PATH!"
            SET "ERROR_FLAG=1"
        )
    ) ELSE (
        ECHO [SKIP] Directory already exists: !CURRENT_PATH!
        CALL :Log "SKIP: Directory already exists: !CURRENT_PATH!"
    )
)

IF "!ERROR_FLAG!"=="1" (
    ECHO.
    ECHO [CRITICAL] One or more directories failed to create. Aborting system setup.
    CALL :Log "CRITICAL: Directory creation failed."
    EXIT /B 1
)

ECHO.
ECHO [SUCCESS] All core directories confirmed to exist within "!INSTALL_ROOT!".
CALL :Log "SUCCESS: All core directories confirmed to exist."
CALL :Log "01_Setup_System.bat completed successfully."

EXIT /B 0
