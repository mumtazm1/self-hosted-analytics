@echo off
echo Updating Self-Hosted Analytics Stack...
echo.
echo Step 1: Pulling latest images...
docker-compose pull
echo.
echo Step 2: Stopping current services...
docker-compose down
echo.
echo Step 3: Starting with updated images...
docker-compose up -d
echo.
echo Update complete! Services restarted with latest versions.
echo.
echo n8n:       http://localhost:5678
echo Metabase:  http://localhost:3000
echo PostgreSQL: localhost:5432 (user: admin)
echo.
pause

