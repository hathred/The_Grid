:: WARNING: This is a generated template from 2_run_pipeline_dryrun.bat (Source Folder: 210_Project_Dev_Tools_Summarize_bak)
:: Check the token replacements (__XXX__) for correctness.

@echo off
set "PIPELINE_DIR=__ECOSYSTEM_ROOT__\990_Project_Automation\Pipeline"
set "CONFIG_PATH=__ECOSYSTEM_ROOT__\990_Project_Automation\Pipeline\config.yaml"

echo [DRY RUN] Starting DML Pipeline Simulation...
echo           Source: %PIPELINE_DIR%
echo           Config: %CONFIG_PATH%
echo.

python "%PIPELINE_DIR%\grok_main.py" --config "%CONFIG_PATH%" --dry-run

echo.
echo [DRY RUN COMPLETE]
echo Log: __ECOSYSTEM_ROOT__\995_Project_Logs\
pause