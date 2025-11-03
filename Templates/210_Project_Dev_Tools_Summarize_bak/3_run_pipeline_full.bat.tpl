:: WARNING: This is a generated template from 3_run_pipeline_full.bat (Source Folder: 210_Project_Dev_Tools_Summarize_bak)
:: Check the token replacements (__XXX__) for correctness.

@echo off
REM ========================================
REM DML Pipeline - FULL RUN MODE
REM ========================================

set "PIPELINE_DIR=__ECOSYSTEM_ROOT__\990_Project_Automation\Pipeline"
set "CONFIG_PATH=__ECOSYSTEM_ROOT__\990_Project_Automation\Pipeline\config.yaml"

echo.
echo [FULL RUN] Starting DML Pipeline with --force...
echo.

python "%PIPELINE_DIR%\grok_main.py" --config "%CONFIG_PATH%" --force

echo.
echo [FULL RUN COMPLETE]
echo Output: __ECOSYSTEM_ROOT__\210_Project_Dev_Tools\Summarize\output\
echo Log:    __ECOSYSTEM_ROOT__\995_Project_Logs\
pause