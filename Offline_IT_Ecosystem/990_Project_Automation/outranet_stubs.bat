@echo off
set PROJECT_ROOT=Offline_IT_Ecosystem
set INSTRUCTIONS_FILE=INSTRUCTIONS.MD

echo Creating project structure in %PROJECT_ROOT%...

REM --- Major Component List ---
set COMPONENTS=^
    01_Infrastructure_LAN ^
    02_DataWarehouse_DW ^
    03_DataTransformation_dbt ^
    04_SemanticLayer_Cube ^
    05_PresentationLayer_Frontend ^
    06_DataScience_MLOps ^
    07_DevOps_CI_CD ^
    08_System_Automation ^
    09_Offline_Archival ^
    10_Auxiliary_Services

mkdir %PROJECT_ROOT%
cd %PROJECT_ROOT%

for %%i in (%COMPONENTS%) do (
    echo Creating directory: %%i
    mkdir %%i
    
    echo # Setup Instructions for %%i > %%i\%INSTRUCTIONS_FILE%
    echo. >> %%i\%INSTRUCTIONS_FILE%
    echo ## Goal >> %%i\%INSTRUCTIONS_FILE%
    echo Set up and configure the %%i component for **completely offline operation**. >> %%i\%INSTRUCTIONS_FILE%
    echo. >> %%i\%INSTRUCTIONS_FILE%
    echo ## Key Dependencies >> %%i\%INSTRUCTIONS_FILE%
    
    REM Custom instruction snippets based on component name
    if "%%i"=="01_Infrastructure_LAN" (
        echo * Physical Air Gap, Local DHCP, Local DNS. >> %%i\%INSTRUCTIONS_FILE%
    ) else if "%%i"=="02_DataWarehouse_DW" (
        echo * PostgreSQL/Greenplum installation, Initial data load (staging tables). >> %%i\%INSTRUCTIONS_FILE%
    ) else if "%%i"=="03_DataTransformation_dbt" (
        echo * dbt Core CLI setup, Develop base data mart SQL models. >> %%i\%INSTRUCTIONS_FILE%
    ) else if "%%i"=="04_SemanticLayer_Cube" (
        echo * Cube installation, Schema definition for core business metrics (e.g., MRR). >> %%i\%INSTRUCTIONS_FILE%
    ) else if "%%i"=="05_PresentationLayer_Frontend" (
        echo * React/D3.js environment, API connection to the Semantic Layer. >> %%i\%INSTRUCTIONS_FILE%
    ) else if "%%i"=="06_DataScience_MLOps" (
        echo * JupyterLab setup, Local MLflow tracking, Offline package library usage. >> %%i\%INSTRUCTIONS_FILE%
    ) else if "%%i"=="07_DevOps_CI_CD" (
        echo * Gitea/GitLab CE (Source Control), Jenkins/Drone CI (Automation). >> %%i\%INSTRUCTIONS_FILE%
    ) else if "%%i"=="08_System_Automation" (
        echo * Airflow/Prefect deployment, Orchestration of daily metric calculation jobs. >> %%i\%INSTRUCTIONS_FILE%
    ) else if "%%i"=="09_Offline_Archival" (
        echo * ZFS snapshot configuration, LTO Tape procedure definition. >> %%i\%INSTRUCTIONS_FILE%
    ) else if "%%i"=="10_Auxiliary_Services" (
        echo * Keycloak (Identity), ELK Stack (Monitoring), DokuWiki (Documentation). >> %%i\%INSTRUCTIONS_FILE%
    ) else (
        echo * Add specific component dependencies here. >> %%i\%INSTRUCTIONS_FILE%
    )
    
    echo. >> %%i\%INSTRUCTIONS_FILE%
    echo ## Next Steps >> %%i\%INSTRUCTIONS_FILE%
    echo 1. Install necessary offline software packages. >> %%i\%INSTRUCTIONS_FILE%
    echo 2. Configure environment variables and credentials. >> %%i\%INSTRUCTIONS_FILE%
    echo 3. Write component-specific configuration files. >> %%i\%INSTRUCTIONS_FILE%
)

cd ..
echo.
echo Directory structure created successfully in ./%PROJECT_ROOT%/
echo Each folder contains a starting %INSTRUCTIONS_FILE% file.

pause