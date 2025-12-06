#!/bin/bash
# ========================================
# Self-Hosted Analytics - Full Backup
# ========================================

# Source common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "========================================"
echo "Self-Hosted Analytics - Full Backup"
echo "========================================"
echo

# Generate timestamp for backup file names
timestamp=$(date +%Y%m%d_%H%M%S)

echo "Creating backups with timestamp: $timestamp"
echo

# Create backup directory if it doesn't exist
ensure_backup_dir

echo "[1/3] Backing up PostgreSQL databases..."
if ! docker exec postgres pg_dumpall -U admin > "$BACKUP_DIR/backup_postgres_${timestamp}.sql"; then
    error "PostgreSQL backup failed!"
    exit 1
fi
success "PostgreSQL backup complete"
echo

echo "[2/3] Backing up n8n volume (workflows and credentials)..."
if ! docker run --rm \
    -v n8n_data:/data \
    -v "$BACKUP_DIR":/backup \
    alpine tar czf "/backup/backup_n8n_${timestamp}.tar.gz" -C /data .; then
    error "n8n volume backup failed!"
    exit 1
fi
success "n8n volume backup complete"
echo

echo "[3/3] Backing up Prefect volume..."
if ! docker run --rm \
    -v prefect_data:/data \
    -v "$BACKUP_DIR":/backup \
    alpine tar czf "/backup/backup_prefect_${timestamp}.tar.gz" -C /data .; then
    error "Prefect volume backup failed!"
    exit 1
fi
success "Prefect volume backup complete"
echo

echo "========================================"
echo "SUCCESS: All backups completed!"
echo "========================================"
echo
echo "Backup files saved to: $BACKUP_DIR/"
echo "  - backup_postgres_${timestamp}.sql"
echo "  - backup_n8n_${timestamp}.tar.gz"
echo "  - backup_prefect_${timestamp}.tar.gz"
echo

pause
