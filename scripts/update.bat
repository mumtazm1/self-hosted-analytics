@echo off
echo ========================================
echo ⚠️  IMPORTANT: BACKUP FIRST! ⚠️
echo ========================================
echo.
echo It's HIGHLY RECOMMENDED to backup before updating.
echo.
echo Options:
echo 1. Continue without backup (risky)
echo 2. Cancel and run backup.bat first
echo.
choice /C 12 /N /M "Choose [1] Continue, [2] Cancel: "
if errorlevel 2 goto :cancel
if errorlevel 1 goto :proceed

:proceed
echo.
echo Updating Self-Hosted Analytics Stack...
echo.
echo Step 1: Pulling latest images...
docker-compose -f ..\docker-compose.yml pull
echo.
echo Step 2: Stopping current services (data preserved)...
docker-compose -f ..\docker-compose.yml down
echo.
echo Step 3: Starting with updated images...
docker-compose -f ..\docker-compose.yml up -d
echo.
echo Update complete! Services restarted with latest versions.
echo.
echo n8n:       http://localhost:5678
echo Metabase:  http://localhost:3000
echo Prefect:   http://localhost:4200
echo PostgreSQL: localhost:5432 (user: admin)
echo.
pause
goto :end

:cancel
echo.
echo Cancelled. Please run backup.bat first.
echo.
pause
goto :end

:end

