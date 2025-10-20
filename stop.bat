@echo off
echo Stopping Self-Hosted Analytics Stack...
echo.
echo NOTE: This keeps all your data safe in Docker volumes.
docker-compose down
echo.
echo Services stopped! (Data preserved)
pause

