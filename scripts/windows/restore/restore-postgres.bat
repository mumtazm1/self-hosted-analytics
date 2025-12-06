@echo off
echo ========================================
echo Restore PostgreSQL from Backup
echo ========================================
echo.
echo WARNING: This will restore PostgreSQL databases from a backup file.
echo This will OVERWRITE current database contents!
echo.
echo Available backup files:
dir /B /O-D ..\..\backups\backup_postgres_*.sql 2>nul
if %errorlevel% neq 0 (
    echo ERROR: No PostgreSQL backup files found in backups\ folder
    pause
    exit /b 1
)
echo.
set /p backup_file="Enter the backup filename (e.g., backup_postgres_20251108_120000.sql): "
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
echo Stopping services that depend on PostgreSQL...
docker-compose -f ..\..\docker-compose.yml stop metabase prefect n8n
echo.
echo Restoring PostgreSQL databases...
type "..\..\backups\%backup_file%" | docker exec -i postgres psql -U admin postgres
if %errorlevel% neq 0 (
    echo ERROR: Restore failed!
    goto :error
)
echo.
echo ✓ PostgreSQL restore complete
echo.
echo Restarting services...
docker-compose -f ..\..\docker-compose.yml start metabase prefect n8n
echo.
echo ========================================
echo SUCCESS: PostgreSQL restored!
echo ========================================
echo.
echo Services restarted. Please verify your data:
echo   - Metabase: http://localhost:3000
echo   - Prefect: http://localhost:4200
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
echo Restarting services...
docker-compose -f ..\..\docker-compose.yml start metabase prefect n8n
pause
exit /b 1

