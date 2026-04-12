#!/bin/bash
# ========================================
# Self-Hosted Analytics - Common Functions
# ========================================
# Shared functions and variables for all scripts
# Source this file: source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Resolve script directory (works even with symlinks)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"
BACKUP_DIR="$PROJECT_ROOT/backups"

# Load .env so scripts use the same secrets and names the stack was
# installed with. Falls back to defaults if .env is missing (pre-install).
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "$PROJECT_ROOT/.env"
    set +a
fi

: "${COMPOSE_PROJECT_NAME:=sha}"
: "${POSTGRES_HOST:=postgres}"
: "${POSTGRES_USER:=admin}"
: "${POSTGRES_DB:=analytics}"

# Container name is the compose service's container_name, which defaults
# to ${POSTGRES_HOST}. Keep these two in lockstep if you rename either.
POSTGRES_CONTAINER="${POSTGRES_HOST}"

# Named volumes scoped to the project name. Must match docker-compose.yml.
N8N_VOLUME="${COMPOSE_PROJECT_NAME}_n8n_data"
PREFECT_VOLUME="${COMPOSE_PROJECT_NAME}_prefect_data"
POSTGRES_VOLUME="${COMPOSE_PROJECT_NAME}_postgres_data"

# Detect docker compose command (v2 vs v1)
if docker compose version &>/dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# Colors for output (optional, degrades gracefully)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Print success message
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error message (to stderr)
error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

# Print warning message
warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Yes/No prompt function
# Usage: if confirm_action "Are you sure?"; then ... fi
confirm_action() {
    local prompt="${1:-Are you sure?}"
    read -p "$prompt [y/N] " response
    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# Wait for user to press Enter
pause() {
    read -p "Press Enter to continue..."
}

# Run docker compose command with proper file path
docker_compose() {
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" "$@"
}

# Check if a container is running
is_container_running() {
    local container_name="$1"
    docker ps --format '{{.Names}}' | grep -q "^${container_name}$"
}

# Wait for postgres to be healthy
wait_for_postgres() {
    echo "Waiting for PostgreSQL to be ready..."
    local max_attempts=30
    local attempt=1
    while [[ $attempt -le $max_attempts ]]; do
        if docker exec "$POSTGRES_CONTAINER" pg_isready -U "$POSTGRES_USER" &>/dev/null; then
            success "PostgreSQL is ready"
            return 0
        fi
        echo "  Attempt $attempt/$max_attempts..."
        sleep 2
        ((attempt++))
    done
    error "PostgreSQL did not become ready in time"
    return 1
}

# Create backup directory if it doesn't exist
ensure_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
    fi
}
