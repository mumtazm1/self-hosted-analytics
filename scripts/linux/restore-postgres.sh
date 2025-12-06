#!/bin/bash
# ========================================
# Restore PostgreSQL from Backup
# ========================================

# Source common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "========================================"
echo "Restore PostgreSQL from Backup"
echo "========================================"
echo
warning "This will restore PostgreSQL databases from a backup file."
warning "This will OVERWRITE current database contents!"
echo

echo "Available backup files:"
backup_files=$(ls -t "$BACKUP_DIR"/backup_postgres_*.sql 2>/dev/null)
if [[ -z "$backup_files" ]]; then
    error "No PostgreSQL backup files found in $BACKUP_DIR/"
    pause
    exit 1
fi

# List files with numbers for selection
echo "$backup_files" | while read -r file; do
    echo "  $(basename "$file")"
done
echo

read -p "Enter the backup filename (e.g., backup_postgres_20251108_120000.sql): " backup_file

if [[ ! -f "$BACKUP_DIR/$backup_file" ]]; then
    error "File not found: $backup_file"
    pause
    exit 1
fi

echo
echo "You are about to restore from: $backup_file"
echo

if ! confirm_action "Are you sure you want to continue?"; then
    echo
    echo "Restore cancelled."
    pause
    exit 0
fi

echo
echo "Stopping services that depend on PostgreSQL..."
docker_compose stop metabase prefect n8n

echo
echo "Dropping existing application databases for clean restore..."
docker exec postgres psql -U admin -d postgres -c "DROP DATABASE IF EXISTS metabase;"
docker exec postgres psql -U admin -d postgres -c "DROP DATABASE IF EXISTS prefect;"
docker exec postgres psql -U admin -d postgres -c "DROP DATABASE IF EXISTS n8n;"
docker exec postgres psql -U admin -d postgres -c "DROP DATABASE IF EXISTS analytics;"

echo
echo "Restoring PostgreSQL databases..."
if ! cat "$BACKUP_DIR/$backup_file" | docker exec -i postgres psql -U admin postgres; then
    error "Restore failed!"
    echo
    echo "Restarting services..."
    docker_compose start metabase prefect n8n
    pause
    exit 1
fi

echo
success "PostgreSQL restore complete"
echo

echo "Restarting services..."
docker_compose start metabase prefect n8n

echo
echo "========================================"
echo "SUCCESS: PostgreSQL restored!"
echo "========================================"
echo
echo "Services restarted. Please verify your data:"
echo "  - Metabase: http://localhost:3000"
echo "  - Prefect: http://localhost:4200"
echo

pause
