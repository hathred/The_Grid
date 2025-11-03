:: WARNING: This is a generated template from add_component_OLD.bat (Source Folder: 990_Project_Automation_Automation_Scripts)
:: Check the token replacements (__XXX__) for correctness.

@echo off
setlocal
set PROJECT_ROOT=__ECOSYSTEM_ROOT__
set INSTRUCTIONS_FILE=INSTRUCTIONS.MD
set MANIFEST_FILE=project_file_structure_manifest.json

echo.
echo ===================================================
echo Component Directory Creation Tool (File System Only)
echo Target Root: %PROJECT_ROOT%
echo ===================================================

if not exist "%PROJECT_ROOT%" (
    echo Error: Project root directory "%PROJECT_ROOT%" not found.
    echo Please ensure you are in the correct directory. Aborting.
    goto :eof
)

REM --- Find Highest Component Number ---
REM This finds the highest existing component number and adds 10
set MAX_NUM=0
for /d %%d in ("%PROJECT_ROOT%\*_*") do (
    for /f "tokens=1 delims=_" %%n in ("%%~nxd") do (
        if "%%n" neq "" (
            if %%n gtr !MAX_NUM! set MAX_NUM=%%n
        )
    )
)
set /a NEW_NUM=%MAX_NUM% + 10
if %NEW_NUM% leq 10 set NEW_NUM=110 REM Ensures consistent numbering (10, 20, ..., 100, 110, 120...)

set /p COMPONENT_NAME="Enter the New Component Name (e.g., Security_Audit): "
if not defined COMPONENT_NAME (
    echo Component name cannot be empty. Aborting.
    goto :eof
)

set /p RESPONSIBLE_TEAM="Enter Responsible Team (e.g., Security_Ops): "
if not defined RESPONSIBLE_TEAM set RESPONSIBLE_TEAM=TBD

set /p COMPONENT_GOAL="Enter Component Goal (short description): "
if not defined COMPONENT_GOAL set COMPONENT_GOAL=To be defined later.

REM --- Format Directory Name and Path ---
set COMPONENT_SAFE_NAME=%COMPONENT_NAME: =_%
set COMPONENT_SAFE_NAME=%COMPONENT_SAFE_NAME:/=_%
set COMPONENT_SAFE_NAME=%COMPONENT_SAFE_NAME::=_%
set COMPONENT_DIR_NAME=%NEW_NUM%_%COMPONENT_SAFE_NAME%
set COMPONENT_PATH=%PROJECT_ROOT%\%COMPONENT_DIR_NAME%

echo.
echo New Directory: %COMPONENT_PATH%
echo.

REM --- Create Directory and INSTRUCTIONS.MD File ---
mkdir "%COMPONENT_PATH%"

echo # Setup Instructions for %COMPONENT_NAME% > "%COMPONENT_PATH%\%INSTRUCTIONS_FILE%"
echo. >> "%COMPONENT_PATH%\%INSTRUCTIONS_FILE%"
echo ## Goal >> "%COMPONENT_PATH%\%INSTRUCTIONS_FILE%"
echo %COMPONENT_GOAL% >> "%COMPONENT_PATH%\%INSTRUCTIONS_FILE%"
echo. >> "%COMPONENT_PATH%\%INSTRUCTIONS_FILE%"
echo ## Key Dependencies >> "%COMPONENT_PATH%\%INSTRUCTIONS_FILE%"
echo * List all software, package mirrors, and internal services this component relies on. >> "%COMPONENT_PATH%\%INSTRUCTIONS_FILE%"
echo. >> "%COMPONENT_PATH%\%INSTRUCTIONS_FILE%"
echo ## Configuration Steps >> "%COMPONENT_PATH%\%INSTRUCTIONS_FILE%"
echo 1. Describe the installation process here. >> "%COMPONENT_PATH%\%INSTRUCTIONS_FILE%"
echo 2. Document the setup of the primary configuration files. >> "%COMPONENT_PATH%\%INSTRUCTIONS_FILE%"

REM --- Append to JSON Manifest using PowerShell ---
set JSON_FRAGMENT={^
    "component_number": %NEW_NUM%,^
    "component_name": "%COMPONENT_NAME%",^
    "directory_path": "%COMPONENT_PATH%",^
    "responsible_team": "%RESPONSIBLE_TEAM%",^
    "component_goal": "%COMPONENT_GOAL%",^
    "creation_timestamp": "%DATE% %TIME%"^
}

powershell -Command " \"$newEntry = '%JSON_FRAGMENT%'; Get-Content %PROJECT_ROOT%/%MANIFEST_FILE% | ForEach-Object { $_ -replace '  \]', \",`n\$newEntry`n  \]\" } | Set-Content %PROJECT_ROOT%/%MANIFEST_FILE%"

if errorlevel 1 (
    echo.
    echo WARNING: Failed to update the JSON manifest file using PowerShell.
    echo Please manually verify and update the %MANIFEST_FILE%.
) else (
    echo Success: Directory and instructions file created, and manifest updated.
)

endlocal
pause