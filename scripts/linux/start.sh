#!/bin/bash
# ========================================
# Start Self-Hosted Analytics Stack
# ========================================

# Source common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "Starting Self-Hosted Analytics Stack..."
docker_compose up -d

echo
echo "Services started!"
echo
echo "n8n:        http://localhost:5678"
echo "Metabase:   http://localhost:3000"
echo "Prefect:    http://localhost:4200"
echo "PostgreSQL: localhost:5432 (user: admin)"
echo

pause
