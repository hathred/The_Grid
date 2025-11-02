@echo off
REM Install Python dependencies from pipeline dir
set PIPELINE_DIR=E:\NextGen\Offline_IT_Ecosystem\990_Project_Automation\Pipeline

if exist "%PIPELINE_DIR%\requirements.txt" (
    pip install -r "%PIPELINE_DIR%\requirements.txt" --no-warn-script-location
    echo Dependencies installed.
) else (
    echo requirements.txt not found in %PIPELINE_DIR%
)
pause