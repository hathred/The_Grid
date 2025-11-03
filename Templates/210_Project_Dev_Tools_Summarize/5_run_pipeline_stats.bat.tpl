:: WARNING: This is a generated template from 5_run_pipeline_stats.bat (Source Folder: 210_Project_Dev_Tools_Summarize)
:: Check the token replacements (__XXX__) for correctness.

@echo off
set "PIPELINE_DIR=__ECOSYSTEM_ROOT__\990_Project_Automation\Pipeline"
set "CONFIG_PATH=__ECOSYSTEM_ROOT__\990_Project_Automation\Pipeline\config.yaml"

echo.
echo [STATS RUN] Generating DML_SUMMARY.md...
echo.

python "%PIPELINE_DIR%\grok_main.py" --config "%CONFIG_PATH%" --stats

echo.
echo [STATS COMPLETE]
echo DML_SUMMARY.md → __ECOSYSTEM_ROOT__\210_Project_Dev_Tools\Summarize\
pause