@echo off
echo Starting Self-Hosted Analytics Stack...
docker-compose -f ..\docker-compose.yml up -d
echo.
echo Services started!
echo.
echo n8n:       http://localhost:5678
echo Metabase:  http://localhost:3000
echo Prefect:   http://localhost:4200
echo Airbyte:   http://localhost:8000
echo PostgreSQL: localhost:5432 (user: admin)
echo.
pause

