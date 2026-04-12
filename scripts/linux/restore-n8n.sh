#!/bin/bash
# ========================================
# Restore n8n Volume from Backup
# ========================================

# Source common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "========================================"
echo "Restore n8n Volume from Backup"
echo "========================================"
echo
warning "This will restore n8n workflows and credentials from backup."
warning "This will OVERWRITE your current n8n data!"
echo

echo "Available backup files:"
backup_files=$(ls -t "$BACKUP_DIR"/backup_n8n_*.tar.gz 2>/dev/null)
if [[ -z "$backup_files" ]]; then
    error "No n8n backup files found in $BACKUP_DIR/"
    pause
    exit 1
fi

echo "$backup_files" | while read -r file; do
    echo "  $(basename "$file")"
done
echo

read -p "Enter the backup filename (e.g., backup_n8n_20251108_120000.tar.gz): " backup_file

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
echo "Stopping n8n..."
docker_compose stop n8n

echo
echo "Clearing n8n volume..."
docker run --rm -v "$N8N_VOLUME":/data alpine sh -c "rm -rf /data/*"

echo
echo "Restoring n8n volume from backup..."
if ! docker run --rm \
    -v "$N8N_VOLUME":/data \
    -v "$BACKUP_DIR":/backup \
    alpine tar xzf "/backup/$backup_file" -C /data; then
    error "Restore failed!"
    echo "Starting n8n..."
    docker_compose start n8n
    pause
    exit 1
fi

echo
success "n8n volume restore complete"
echo

echo "Starting n8n..."
docker_compose start n8n

echo
echo "========================================"
echo "SUCCESS: n8n restored!"
echo "========================================"
echo
echo "n8n is starting up. Access at: http://localhost:5678"
echo "Wait 30 seconds before accessing."
echo

pause
