@echo off
echo ========================================
echo Restore n8n Volume from Backup
echo ========================================
echo.
echo WARNING: This will restore n8n workflows and credentials from backup.
echo This will OVERWRITE your current n8n data!
echo.
echo Available backup files:
dir /B /O-D ..\..\backups\backup_n8n_*.tar.gz 2>nul
if %errorlevel% neq 0 (
    echo ERROR: No n8n backup files found in backups\ folder
    pause
    exit /b 1
)
echo.
set /p backup_file="Enter the backup filename (e.g., backup_n8n_20251108_120000.tar.gz): "
if not exist "..\..\backups\%backup_file%" (
    echo ERROR: File not found: %backup_file%
    pause
    exit /b 1
)
echo.
echo You are about to restore from: %backup_file%
echo.
choice /C YN /M "Are you sure you want to continue? [Y/N]"
if errorlevel 2 goto :cancel
if errorlevel 1 goto :proceed

:proceed
echo.
echo Stopping n8n...
docker-compose -f ..\..\docker-compose.yml stop n8n
echo.
echo Clearing n8n volume...
docker run --rm -v n8n_data:/data alpine sh -c "rm -rf /data/*"
echo.
echo Restoring n8n volume from backup...
docker run --rm -v n8n_data:/data -v %cd%\..\..\backups:/backup alpine tar xzf /backup/%backup_file% -C /data
if %errorlevel% neq 0 (
    echo ERROR: Restore failed!
    goto :error
)
echo.
echo ✓ n8n volume restore complete
echo.
echo Starting n8n...
docker-compose -f ..\..\docker-compose.yml start n8n
echo.
echo ========================================
echo SUCCESS: n8n restored!
echo ========================================
echo.
echo n8n is starting up. Access at: http://localhost:5678
echo Wait 30 seconds before accessing.
echo.
pause
exit /b 0

:cancel
echo.
echo Restore cancelled.
pause
exit /b 0

:error
echo.
echo ========================================
echo RESTORE FAILED - See error above
echo ========================================
echo Starting n8n...
docker-compose -f ..\..\docker-compose.yml start n8n
pause
exit /b 1

