:: WARNING: This is a generated template from 6_launch_web_dashboard.bat (Source Folder: 210_Project_Dev_Tools_Summarize)
:: Check the token replacements (__XXX__) for correctness.

@echo off
set "PIPELINE_DIR=__ECOSYSTEM_ROOT__\990_Project_Automation\Pipeline"

echo.
echo [WEB DASHBOARD] Launching DML Viewer...
echo                 http://localhost:8000
echo.

python "%PIPELINE_DIR%\grok_main.py" --web

pause