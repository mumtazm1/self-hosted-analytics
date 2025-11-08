@echo off
echo Restarting Self-Hosted Analytics Stack...
docker-compose -f ..\docker-compose.yml restart
echo.
echo Services restarted!
echo.
echo n8n:       http://localhost:5678
echo Metabase:  http://localhost:3000
echo Prefect:   http://localhost:4200
echo PostgreSQL: localhost:5432 (user: admin)
echo.
pause

