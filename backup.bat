@echo off
echo Creating PostgreSQL backup...
echo.
docker exec postgres_main pg_dumpall -U admin > ./backups/backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time::=-%.sql
echo.
echo Backup complete! Saved to ./backups/
echo.
pause

