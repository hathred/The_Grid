@echo off
set "PIPELINE_DIR=E:\NextGen\Offline_IT_Ecosystem\990_Project_Automation\Pipeline"

echo.
echo [WEB DASHBOARD] Launching DML Viewer...
echo                 http://localhost:8000
echo.

python "%PIPELINE_DIR%\grok_main.py" --web

pause