#!/bin/bash
# ========================================
# View Service Logs
# ========================================

# Source common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "Showing logs for all services..."
echo "Press Ctrl+C to exit"
echo

docker_compose logs -f
