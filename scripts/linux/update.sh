#!/bin/bash
# ========================================
# Update Self-Hosted Analytics Stack
# ========================================

# Source common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "========================================"
echo "IMPORTANT: BACKUP FIRST!"
echo "========================================"
echo
echo "It's HIGHLY RECOMMENDED to backup before updating."
echo
echo "Options:"
echo "1. Continue without backup (risky)"
echo "2. Cancel and run backup.sh first"
echo

read -p "Choose [1] Continue, [2] Cancel: " choice

case "$choice" in
    1)
        echo
        echo "Updating Self-Hosted Analytics Stack..."
        echo
        echo "Step 1: Pulling latest images..."
        docker_compose pull
        echo
        echo "Step 2: Stopping current services (data preserved)..."
        docker_compose down
        echo
        echo "Step 3: Starting with updated images..."
        docker_compose up -d
        echo
        echo "Update complete! Services restarted with latest versions."
        echo
        echo "n8n:        http://localhost:5678"
        echo "Metabase:   http://localhost:3000"
        echo "Prefect:    http://localhost:4200"
        echo "PostgreSQL: localhost:5432 (user: admin)"
        echo
        ;;
    2|*)
        echo
        echo "Cancelled. Please run backup.sh first."
        echo
        ;;
esac

pause
