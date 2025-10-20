@echo off
echo Starting Self-Hosted Analytics Stack...
docker-compose up -d
echo.
echo Services started!
echo.
echo n8n:       http://localhost:5678
echo Metabase:  http://localhost:3000
echo PostgreSQL: localhost:5432 (user: admin)
echo.
pause

