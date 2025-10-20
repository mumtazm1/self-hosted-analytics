@echo off
echo Restarting Self-Hosted Analytics Stack...
docker-compose restart
echo.
echo Services restarted!
echo.
echo n8n:       http://localhost:5678
echo Metabase:  http://localhost:3000
echo PostgreSQL: localhost:5432 (user: owais)
echo.
pause

