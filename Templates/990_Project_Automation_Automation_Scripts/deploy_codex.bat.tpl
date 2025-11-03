:: WARNING: This is a generated template from deploy_codex.bat (Source Folder: 990_Project_Automation_Automation_Scripts)
:: Check the token replacements (__XXX__) for correctness.

@echo off
REM Deploy from Codex to E:\Deploy\Offline_IT_Ecosystem
REM Assumes Codex filled; Offline after this.

set DEPLOY_ROOT=E:\Deploy\Offline_IT_Ecosystem
set CODEX_ROOT=__OFFLINE_FILES__\Installers

if not exist %CODEX_ROOT% (
    echo ERROR: Codex not stocked. Run harvest_deps.ps1 first.
    pause
    exit /b 1
)

robocopy %CODEX_ROOT% %DEPLOY_ROOT% /E /MT:8 /R:3 /W:5 /LOG:deploy_log.txt
echo Deployment complete. Run sort_ecosystem.bat in %DEPLOY_ROOT%.

REM Post-deploy: Enforce structure
call %DEPLOY_ROOT%\990_Project_Automation\sort_ecosystem.bat

pause