:: WARNING: This is a generated template from 1_setup_environment.bat (Source Folder: 210_Project_Dev_Tools_Summarize_bak)
:: Check the token replacements (__XXX__) for correctness.

@echo off
REM Install Python dependencies from pipeline dir
set PIPELINE_DIR=__ECOSYSTEM_ROOT__\990_Project_Automation\Pipeline

if exist "%PIPELINE_DIR%\requirements.txt" (
    pip install -r "%PIPELINE_DIR%\requirements.txt" --no-warn-script-location
    echo Dependencies installed.
) else (
    echo requirements.txt not found in %PIPELINE_DIR%
)
pause