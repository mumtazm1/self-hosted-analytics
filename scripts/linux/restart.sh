#!/bin/bash
# ========================================
# Restart Self-Hosted Analytics Stack
# ========================================

# Source common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "Restarting Self-Hosted Analytics Stack..."
docker_compose restart

echo
echo "Services restarted!"
echo
echo "n8n:        http://localhost:5678"
echo "Metabase:   http://localhost:3000"
echo "Prefect:    http://localhost:4200"
echo "PostgreSQL: localhost:5432 (user: admin)"
echo

pause
