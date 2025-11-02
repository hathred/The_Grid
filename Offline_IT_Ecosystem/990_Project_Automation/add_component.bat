@echo off
setlocal enabledelayedexpansion
set PROJECT_ROOT=Offline_IT_Ecosystem
set MANIFEST_FILE=project_file_structure_manifest.json

echo.
echo ===================================================
echo Component Directory Creation Tool (FIXED)
echo Target Root: E:\NextGen\%PROJECT_ROOT%
echo ===================================================

if not exist "%PROJECT_ROOT%" (
    echo Error: Project root directory "%PROJECT_ROOT%" not found. Aborting.
    goto :eof
)

REM --- Find Highest Component Number ---
set MAX_NUM=0
for /d %%d in ("%PROJECT_ROOT%\*_*") do (
    for /f "tokens=1 delims=_" %%n in ("%%~nxd") do (
        set "NUM_STR=%%n"
        if "!NUM_STR!" gtr "!MAX_NUM!" set MAX_NUM=!NUM_STR!
    )
)
set /a NEW_NUM=!MAX_NUM! + 10
if !NEW_NUM! leq 10 set NEW_NUM=110

REM --- Capture User Input ---
set /p COMPONENT_NAME="Enter the New Component Name (e.g., Security_Audit): "
if not defined COMPONENT_NAME (
    echo Component name cannot be empty. Aborting.
    goto :eof
)
set /p RESPONSIBLE_TEAM="Enter Responsible Team (e.g., Security_Ops): "
set /p COMPONENT_GOAL="Enter Component Goal (short description): "

REM --- Format Directory Name and Path ---
set COMPONENT_SAFE_NAME=%COMPONENT_NAME: =_%
set COMPONENT_SAFE_NAME=%COMPONENT_SAFE_NAME:/=_%
set COMPONENT_SAFE_NAME=%COMPONENT_SAFE_NAME::=_%
set COMPONENT_DIR_NAME=!NEW_NUM!_!COMPONENT_SAFE_NAME!
set COMPONENT_PATH=%PROJECT_ROOT%\!COMPONENT_DIR_NAME!

echo.
echo Creating Directory: %COMPONENT_PATH%
echo.

REM --- Create Directory and INSTRUCTIONS.MD File (Simplified) ---
mkdir "%COMPONENT_PATH%"

echo # Setup Instructions for %COMPONENT_NAME% > "%COMPONENT_PATH%\INSTRUCTIONS.MD"
echo. >> "%COMPONENT_PATH%\INSTRUCTIONS.MD"
echo ## Goal >> "%COMPONENT_PATH%\INSTRUCTIONS.MD"
echo %COMPONENT_GOAL% >> "%COMPONENT_PATH%\INSTRUCTIONS.MD"
echo. >> "%COMPONENT_PATH%\INSTRUCTIONS.MD"

REM --- Fix: Append to JSON Manifest using PowerShell ---
REM Create a clean JSON object string on one line for PowerShell to handle easily.
set "JSON_FRAGMENT={\`"component_number\`": !NEW_NUM!, \`"component_name\`": \`"%COMPONENT_NAME%\`", \`"directory_path\`": \`"E:\\NextGen\\%COMPONENT_PATH%\`", \`"responsible_team\`": \`"%RESPONSIBLE_TEAM%\`", \`"component_goal\`": \`"%COMPONENT_GOAL%\`", \`"creation_timestamp\`": \`"%DATE% %TIME%\`"}"

powershell -Command "(gc %PROJECT_ROOT%\%MANIFEST_FILE%) -replace '\\]$', ',%JSON_FRAGMENT%]' | set-content %PROJECT_ROOT%\%MANIFEST_FILE% -Encoding ASCII"

if errorlevel 0 (
    echo Success: Directory created, and manifest updated.
) else (
    echo WARNING: Directory created, but JSON manifest update failed. Please check %MANIFEST_FILE%.
)

endlocal
pause