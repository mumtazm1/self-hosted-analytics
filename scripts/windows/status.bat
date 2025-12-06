@echo off
echo Checking service status...
echo.
docker-compose -f ..\docker-compose.yml ps
echo.
pause

