@echo off
echo Creating PostgreSQL backup...
echo.
docker exec postgres_main pg_dumpall -U owais > ./backups/backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.sql
echo.
echo Backup complete! Saved to ./backups/
echo.
pause

