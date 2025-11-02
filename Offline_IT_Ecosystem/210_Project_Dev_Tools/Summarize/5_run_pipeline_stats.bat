@echo off
set "PIPELINE_DIR=E:\NextGen\Offline_IT_Ecosystem\990_Project_Automation\Pipeline"
set "CONFIG_PATH=E:\NextGen\Offline_IT_Ecosystem\990_Project_Automation\Pipeline\config.yaml"

echo.
echo [STATS RUN] Generating DML_SUMMARY.md...
echo.

python "%PIPELINE_DIR%\grok_main.py" --config "%CONFIG_PATH%" --stats

echo.
echo [STATS COMPLETE]
echo DML_SUMMARY.md → E:\NextGen\Offline_IT_Ecosystem\210_Project_Dev_Tools\Summarize\
pause