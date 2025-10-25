@echo off
echo Creating PostgreSQL backup...
echo.
set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time::=-%
set timestamp=%timestamp: =0%
docker exec postgres_main pg_dumpall -U admin > ./backups/backup_%timestamp%.sql
echo.
echo Backup complete! Saved to ./backups/
echo.
pause

