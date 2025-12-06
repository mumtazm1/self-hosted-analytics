#!/bin/bash
# ========================================
# Restore Prefect Volume from Backup
# ========================================

# Source common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "========================================"
echo "Restore Prefect Volume from Backup"
echo "========================================"
echo
warning "This will restore Prefect local data from backup."
warning "This will OVERWRITE your current Prefect volume data!"
echo

echo "Available backup files:"
backup_files=$(ls -t "$BACKUP_DIR"/backup_prefect_*.tar.gz 2>/dev/null)
if [[ -z "$backup_files" ]]; then
    error "No Prefect backup files found in $BACKUP_DIR/"
    pause
    exit 1
fi

echo "$backup_files" | while read -r file; do
    echo "  $(basename "$file")"
done
echo

read -p "Enter the backup filename (e.g., backup_prefect_20251108_120000.tar.gz): " backup_file

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
echo "Stopping Prefect..."
docker_compose stop prefect

echo
echo "Clearing Prefect volume..."
docker run --rm -v prefect_data:/data alpine sh -c "rm -rf /data/*"

echo
echo "Restoring Prefect volume from backup..."
if ! docker run --rm \
    -v prefect_data:/data \
    -v "$BACKUP_DIR":/backup \
    alpine tar xzf "/backup/$backup_file" -C /data; then
    error "Restore failed!"
    echo "Starting Prefect..."
    docker_compose start prefect
    pause
    exit 1
fi

echo
success "Prefect volume restore complete"
echo

echo "Starting Prefect..."
docker_compose start prefect

echo
echo "========================================"
echo "SUCCESS: Prefect restored!"
echo "========================================"
echo
echo "Prefect is starting up. Access at: http://localhost:4200"
echo "Wait 30 seconds before accessing."
echo

pause
