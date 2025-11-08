@echo off
echo Showing logs for all services...
echo Press Ctrl+C to exit
echo.
docker-compose -f ..\docker-compose.yml logs -f

