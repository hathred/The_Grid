@echo off
setlocal

echo.
echo =========================================================
echo INITIALIZING ECOSYSTEM SORT (RUNNING PYTHON SCRIPT)
echo Running from: %CD%
echo =========================================================

REM Check if the Python script exists
if not exist "sort_ecosystem.py" (
    echo [ERROR] The Python script sort_ecosystem.py was not found!
    echo Please make sure sort_ecosystem.py is in this directory.
    goto :END
)

REM --- Execute the Python script using the python interpreter ---
REM The '-u' flag ensures unbuffered output for real-time logging.
python -u sort_ecosystem.py

:END
echo.
pause
