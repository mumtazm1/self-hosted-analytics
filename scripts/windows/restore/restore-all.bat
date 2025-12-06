@echo off
echo ========================================
echo FULL DISASTER RECOVERY
echo ========================================
echo.
echo WARNING: This will restore ALL services from backup files!
echo This will OVERWRITE ALL current data!
echo.
echo This script will restore:
echo   1. PostgreSQL (Metabase, Prefect, Airbyte, Analytics)
echo   2. n8n workflows and credentials
echo   3. Prefect local data
echo.
echo.
echo ========================================
echo CRITICAL WARNING
echo ========================================
echo.
echo Only use this if you need to recover from a disaster.
echo Make sure you have the correct backup files!
echo.
choice /C YN /M "Do you want to continue with FULL RECOVERY? [Y/N]"
if errorlevel 2 goto :cancel
if errorlevel 1 goto :proceed

:proceed
echo.
echo ========================================
echo Step 1: Restore PostgreSQL
echo ========================================
echo.
call restore-postgres.bat
if %errorlevel% neq 0 (
    echo PostgreSQL restore failed. Stopping recovery.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Step 2: Restore n8n Volume
echo ========================================
echo.
call restore-n8n.bat
if %errorlevel% neq 0 (
    echo n8n restore failed. PostgreSQL was restored, but n8n may have old data.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Step 3: Restore Prefect Volume
echo ========================================
echo.
echo Available Prefect backup files:
dir /B /O-D ..\..\backups\backup_prefect_*.tar.gz 2>nul
if %errorlevel% neq 0 (
    echo WARNING: No Prefect backup files found. Skipping Prefect restore.
    goto :complete
)
echo.
set /p backup_file="Enter Prefect backup filename (or press ENTER to skip): "
if "%backup_file%"=="" goto :complete

if not exist "..\..\backups\%backup_file%" (
    echo WARNING: File not found. Skipping Prefect restore.
    goto :complete
)

echo Stopping Prefect...
docker-compose -f ..\..\docker-compose.yml stop prefect

echo Clearing Prefect volume...
docker run --rm -v prefect_data:/data alpine sh -c "rm -rf /data/*"

echo Restoring Prefect volume...
docker run --rm -v prefect_data:/data -v %cd%\..\..\backups:/backup alpine tar xzf /backup/%backup_file% -C /data

echo Starting Prefect...
docker-compose -f ..\..\docker-compose.yml start prefect

:complete
echo.
echo ========================================
echo FULL RECOVERY COMPLETE
echo ========================================
echo.
echo All services have been restored from backup.
echo.
echo Access your services:
echo   - n8n: http://localhost:5678
echo   - Metabase: http://localhost:3000
echo   - Prefect: http://localhost:4200
echo.
echo Please verify all data is correct!
echo.
pause
exit /b 0

:cancel
echo.
echo Recovery cancelled.
pause
exit /b 0

