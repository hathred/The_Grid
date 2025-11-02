@echo off
set "PIPELINE_DIR=E:\NextGen\Offline_IT_Ecosystem\990_Project_Automation\Pipeline"
set "CONFIG_PATH=E:\NextGen\Offline_IT_Ecosystem\990_Project_Automation\Pipeline\config.yaml"

echo [DRY RUN] Starting DML Pipeline Simulation...
echo           Source: %PIPELINE_DIR%
echo           Config: %CONFIG_PATH%
echo.

python "%PIPELINE_DIR%\grok_main.py" --config "%CONFIG_PATH%" --dry-run

echo.
echo [DRY RUN COMPLETE]
echo Log: E:\NextGen\Offline_IT_Ecosystem\995_Project_Logs\
pause