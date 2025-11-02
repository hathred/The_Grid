@echo off
REM ========================================
REM DML Pipeline - FULL RUN MODE
REM ========================================

set "PIPELINE_DIR=E:\NextGen\Offline_IT_Ecosystem\990_Project_Automation\Pipeline"
set "CONFIG_PATH=E:\NextGen\Offline_IT_Ecosystem\990_Project_Automation\Pipeline\config.yaml"

echo.
echo [FULL RUN] Starting DML Pipeline with --force...
echo.

python "%PIPELINE_DIR%\grok_main.py" --config "%CONFIG_PATH%" --force

echo.
echo [FULL RUN COMPLETE]
echo Output: E:\NextGen\Offline_IT_Ecosystem\210_Project_Dev_Tools\Summarize\output\
echo Log:    E:\NextGen\Offline_IT_Ecosystem\995_Project_Logs\
pause