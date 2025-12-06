#!/bin/bash
# ========================================
# FULL DISASTER RECOVERY
# ========================================

# Source common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "========================================"
echo "FULL DISASTER RECOVERY"
echo "========================================"
echo
warning "This will restore ALL services from backup files!"
warning "This will OVERWRITE ALL current data!"
echo
echo "This script will restore:"
echo "  1. PostgreSQL (Metabase, Prefect, Analytics databases)"
echo "  2. n8n workflows and credentials"
echo "  3. Prefect local data"
echo

echo "========================================"
echo "CRITICAL WARNING"
echo "========================================"
echo
echo "Only use this if you need to recover from a disaster."
echo "Make sure you have the correct backup files!"
echo

if ! confirm_action "Do you want to continue with FULL RECOVERY?"; then
    echo
    echo "Recovery cancelled."
    pause
    exit 0
fi

echo
echo "========================================"
echo "Step 1: Restore PostgreSQL"
echo "========================================"
echo

# List PostgreSQL backups
echo "Available PostgreSQL backup files:"
pg_backup_files=$(ls -t "$BACKUP_DIR"/backup_postgres_*.sql 2>/dev/null)
if [[ -z "$pg_backup_files" ]]; then
    error "No PostgreSQL backup files found!"
    pause
    exit 1
fi

echo "$pg_backup_files" | while read -r file; do
    echo "  $(basename "$file")"
done
echo

read -p "Enter PostgreSQL backup filename: " pg_backup_file

if [[ ! -f "$BACKUP_DIR/$pg_backup_file" ]]; then
    error "File not found: $pg_backup_file"
    pause
    exit 1
fi

echo "Stopping services that depend on PostgreSQL..."
docker_compose stop metabase prefect n8n

echo "Dropping existing application databases for clean restore..."
docker exec postgres psql -U admin -d postgres -c "DROP DATABASE IF EXISTS metabase;"
docker exec postgres psql -U admin -d postgres -c "DROP DATABASE IF EXISTS prefect;"
docker exec postgres psql -U admin -d postgres -c "DROP DATABASE IF EXISTS n8n;"
docker exec postgres psql -U admin -d postgres -c "DROP DATABASE IF EXISTS analytics;"

echo "Restoring PostgreSQL databases..."
if ! cat "$BACKUP_DIR/$pg_backup_file" | docker exec -i postgres psql -U admin postgres; then
    error "PostgreSQL restore failed. Stopping recovery."
    pause
    exit 1
fi
success "PostgreSQL restored"

echo
echo "========================================"
echo "Step 2: Restore n8n Volume"
echo "========================================"
echo

# List n8n backups
echo "Available n8n backup files:"
n8n_backup_files=$(ls -t "$BACKUP_DIR"/backup_n8n_*.tar.gz 2>/dev/null)
if [[ -z "$n8n_backup_files" ]]; then
    warning "No n8n backup files found. Skipping n8n restore."
else
    echo "$n8n_backup_files" | while read -r file; do
        echo "  $(basename "$file")"
    done
    echo

    read -p "Enter n8n backup filename (or press Enter to skip): " n8n_backup_file

    if [[ -n "$n8n_backup_file" ]]; then
        if [[ -f "$BACKUP_DIR/$n8n_backup_file" ]]; then
            echo "Stopping n8n..."
            docker_compose stop n8n

            echo "Clearing n8n volume..."
            docker run --rm -v n8n_data:/data alpine sh -c "rm -rf /data/*"

            echo "Restoring n8n volume..."
            if docker run --rm \
                -v n8n_data:/data \
                -v "$BACKUP_DIR":/backup \
                alpine tar xzf "/backup/$n8n_backup_file" -C /data; then
                success "n8n restored"
            else
                warning "n8n restore failed, but continuing..."
            fi
        else
            warning "File not found. Skipping n8n restore."
        fi
    else
        echo "Skipping n8n restore."
    fi
fi

echo
echo "========================================"
echo "Step 3: Restore Prefect Volume"
echo "========================================"
echo

# List Prefect backups
echo "Available Prefect backup files:"
prefect_backup_files=$(ls -t "$BACKUP_DIR"/backup_prefect_*.tar.gz 2>/dev/null)
if [[ -z "$prefect_backup_files" ]]; then
    warning "No Prefect backup files found. Skipping Prefect restore."
else
    echo "$prefect_backup_files" | while read -r file; do
        echo "  $(basename "$file")"
    done
    echo

    read -p "Enter Prefect backup filename (or press Enter to skip): " prefect_backup_file

    if [[ -n "$prefect_backup_file" ]]; then
        if [[ -f "$BACKUP_DIR/$prefect_backup_file" ]]; then
            echo "Stopping Prefect..."
            docker_compose stop prefect

            echo "Clearing Prefect volume..."
            docker run --rm -v prefect_data:/data alpine sh -c "rm -rf /data/*"

            echo "Restoring Prefect volume..."
            if docker run --rm \
                -v prefect_data:/data \
                -v "$BACKUP_DIR":/backup \
                alpine tar xzf "/backup/$prefect_backup_file" -C /data; then
                success "Prefect restored"
            else
                warning "Prefect restore failed, but continuing..."
            fi
        else
            warning "File not found. Skipping Prefect restore."
        fi
    else
        echo "Skipping Prefect restore."
    fi
fi

echo
echo "========================================"
echo "Starting All Services"
echo "========================================"
echo

docker_compose start metabase prefect n8n

echo
echo "========================================"
echo "FULL RECOVERY COMPLETE"
echo "========================================"
echo
echo "All services have been restored from backup."
echo
echo "Access your services:"
echo "  - n8n: http://localhost:5678"
echo "  - Metabase: http://localhost:3000"
echo "  - Prefect: http://localhost:4200"
echo
echo "Please verify all data is correct!"
echo

pause
