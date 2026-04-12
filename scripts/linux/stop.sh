#!/bin/bash
# ========================================
# Stop Self-Hosted Analytics Stack
# ========================================

# Source common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "Stopping Self-Hosted Analytics Stack..."
echo
echo "NOTE: This keeps all your data safe in Docker volumes."

docker_compose down

echo
echo "Services stopped! (Data preserved)"

pause
