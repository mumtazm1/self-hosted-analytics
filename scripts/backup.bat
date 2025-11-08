@echo off
echo ========================================
echo Self-Hosted Analytics - Full Backup
echo ========================================
echo.

REM Generate timestamp for backup file names
set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%

echo Creating backups with timestamp: %timestamp%
echo.

REM Create backup directory if it doesn't exist
if not exist "%~dp0..\backups" mkdir "%~dp0..\backups"

echo [1/4] Backing up PostgreSQL databases...
docker exec postgres pg_dumpall -U admin > "%~dp0..\backups\backup_postgres_%timestamp%.sql"
if %errorlevel% neq 0 (
    echo ERROR: PostgreSQL backup failed!
    goto :error
)
echo ✓ PostgreSQL backup complete
echo.

echo [2/4] Backing up n8n volume (workflows and credentials)...
docker run --rm -v n8n_data:/data -v "%~dp0..\backups":/backup alpine tar czf /backup/backup_n8n_%timestamp%.tar.gz -C /data .
if %errorlevel% neq 0 (
    echo ERROR: n8n volume backup failed!
    goto :error
)
echo ✓ n8n volume backup complete
echo.

echo [3/3] Backing up Prefect volume...
docker run --rm -v prefect_data:/data -v "%~dp0..\backups":/backup alpine tar czf /backup/backup_prefect_%timestamp%.tar.gz -C /data .
if %errorlevel% neq 0 (
    echo ERROR: Prefect volume backup failed!
    goto :error
)
echo ✓ Prefect volume backup complete
echo.

echo ========================================
echo SUCCESS: All backups completed!
echo ========================================
echo.
echo Backup files saved to: %~dp0..\backups\
echo   - backup_postgres_%timestamp%.sql
echo   - backup_n8n_%timestamp%.tar.gz
echo   - backup_prefect_%timestamp%.tar.gz
echo.
pause
exit /b 0

:error
echo.
echo ========================================
echo BACKUP FAILED - See error above
echo ========================================
echo.
pause
exit /b 1

