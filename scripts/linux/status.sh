#!/bin/bash
# ========================================
# Check Service Status
# ========================================

# Source common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "Checking service status..."
echo

docker_compose ps

echo

pause
