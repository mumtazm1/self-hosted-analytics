# 🛡️ DATA PROTECTION SYSTEM

## 🔒 Protection Layers

### Layer 1: External Volumes (Primary Protection)

All data volumes are marked as `external: true` in `docker-compose.yml`:

```yaml
volumes:
  postgres_data:
    external: true    # Metabase, Prefect, Analytics, Airbyte
  n8n_data:
    external: true    # n8n workflows & credentials (SQLite)
  prefect_data:
    external: true    # Prefect local storage
  airbyte_data:
    external: true    # Airbyte configs (when added)
```

**What this means:**
- Volumes persist even if `docker-compose down -v` is run (with `-v` flag)
- Data survives container recreation and updates
- Manual deletion required to remove volumes

**How to verify:**
```bash
docker volume ls
# Should show: postgres_data, n8n_data, prefect_data, airbyte_data
```

---

### Layer 2: Comprehensive Backups

The `scripts\backup.bat` script backs up **ALL DATA SOURCES**:

#### What Gets Backed Up:

1. **PostgreSQL Databases** (`backup_postgres_TIMESTAMP.sql`)
   - `metabase` - All dashboards, questions, collections, users
   - `prefect` - Workflow definitions, runs, schedules
   - `analytics` - Your data tables and schemas
   - `airbyte` - Connection configs (when enabled)

2. **n8n Workflows** (`backup_n8n_TIMESTAMP.tar.gz`)
   - SQLite database with all workflows
   - Credentials (encrypted)
   - Execution history
   - Settings and configurations

3. **Prefect Data** (`backup_prefect_TIMESTAMP.tar.gz`)
   - Local flow storage
   - Agent metadata

4. **Airbyte Data** (`backup_airbyte_TIMESTAMP.tar.gz`)
   - When Airbyte is configured

#### Running Backups:

**Manual:**
```batch
cd scripts
backup.bat
```

**Automated (Windows Task Scheduler):**
1. Open Task Scheduler
2. Create Basic Task → Name: "Analytics Backup"
3. Trigger: Daily at 2:00 AM
4. Action: Start a program
5. Program: `C:\Users\YourUser\Projects\self-hosted-analytics\scripts\backup.bat`

---

### Layer 3: Disaster Recovery Scripts

Located in `scripts\restore\`:

#### `restore-postgres.bat`
- Restores all PostgreSQL databases
- Brings back Metabase dashboards, Prefect workflows
- Safe: Stops dependent services during restore

#### `restore-n8n.bat`
- Restores n8n SQLite database
- Recovers all workflows and credentials
- Safe: Stops n8n during restore

#### `restore-all.bat`
- Full disaster recovery
- Restores everything from backups
- Guides you through the process

**Usage:**
```batch
cd scripts\restore
restore-all.bat
# Follow prompts to select backup files
```

---

### Layer 4: Configuration Lock

The `.env` file locks all critical settings:

```env
POSTGRES_HOST=postgres          # Don't change
POSTGRES_PORT=5432              # Don't change
POSTGRES_USER=admin             # Don't change
POSTGRES_PASSWORD=...           # Can change (requires restart)
```

**Why this matters:**
- AI can't accidentally change database connection strings
- Services won't start with wrong configs
- Clear defaults documented

---

## 🚨 Common Scenarios & Solutions

### Scenario 1: "AI changed docker-compose.yml and now services won't start"

**Problem:** Configuration changes broke the stack

**Solution:**
```bash
# 1. Revert changes
git restore docker-compose.yml

# 2. Restart services
docker-compose down
docker-compose up -d

# Your data is safe in the volumes!
```

---

### Scenario 2: "I accidentally ran docker-compose down -v"

**Problem:** Volumes deleted (VERY BAD - should never happen with external volumes)

**Solution:**
```bash
# 1. Stop services
docker-compose down

# 2. Recreate external volumes
docker volume create postgres_data
docker volume create n8n_data
docker volume create prefect_data
docker volume create airbyte_data

# 3. Start services (empty databases)
docker-compose up -d

# 4. Restore from backup
cd scripts\restore
restore-all.bat
```

---

### Scenario 3: "n8n workflows are missing after update"

**Problem:** n8n SQLite database got corrupted or wiped

**Solution:**
```bash
# Restore n8n from backup
cd scripts\restore
restore-n8n.bat

# Select most recent backup file
# n8n will restart with all workflows
```

---

### Scenario 4: "Metabase lost all my dashboards"

**Problem:** Metabase database connection issue or data loss

**Solution:**
```bash
# Restore PostgreSQL (includes Metabase data)
cd scripts\restore
restore-postgres.bat

# Select most recent backup file
# Metabase will restart with all dashboards
```

---

## 📋 Regular Maintenance

### Daily
- ✅ Automated backup runs (if scheduled)

### Weekly
- Run `scripts\backup.bat` manually to verify
- Check `backups\` folder for recent files

### Monthly
- Test restore procedure on a copy
- Verify all services accessible
- Clean up old backups (keep last 30 days)

---

## 🔐 Critical Files - DO NOT DELETE

### Docker Volumes:
- `postgres_data` - All PostgreSQL data
- `n8n_data` - All n8n workflows
- `prefect_data` - Prefect storage
- `airbyte_data` - Airbyte configs

### Configuration Files:
- `docker-compose.yml` - Service definitions
- `.env` - Configuration settings
- `scripts/init-db.sql` - Database initialization

### Backup Directory:
- `backups/` - All backup files (KEEP SAFE!)

---

## ⚠️ What NEVER to Change

### In `docker-compose.yml`:

**NEVER change these:**
```yaml
volumes:
  postgres_data:
    external: true      # NEVER remove external: true
  n8n_data:
    external: true      # NEVER remove external: true
  prefect_data:
    external: true      # NEVER remove external: true
```

**NEVER change these:**
```yaml
DB_TYPE: sqlite                 # n8n uses SQLite, not PostgreSQL
- postgres_data:/var/lib/postgresql/data   # Volume mount paths
- n8n_data:/home/node/.n8n                 # Volume mount paths
```

### In `.env`:

**Be careful changing:**
- `POSTGRES_HOST` - Services won't connect
- `POSTGRES_PORT` - Services won't connect
- `POSTGRES_USER` - Authentication will fail
- `POSTGRES_PASSWORD` - Requires restart of all services

---

## 🎯 Why This Setup is Safe

1. **External Volumes** = Data can't be accidentally deleted
2. **Comprehensive Backups** = Multiple recovery points
3. **Easy Restore Scripts** = 5-minute recovery time
4. **Tested Procedures** = Known to work
5. **Clear Documentation** = Easy to understand and follow

---

## 📞 Emergency Procedures

### "Everything is broken, I need my data back NOW"

1. **Don't panic** - Your data is in backups
2. **Stop making changes** - Don't make it worse
3. **Check volumes exist:**
   ```bash
   docker volume ls
   # If volumes exist, data is probably safe
   ```
4. **Run full restore:**
   ```bash
   cd scripts\restore
   restore-all.bat
   ```
5. **Verify services:**
   - n8n: http://localhost:5678
   - Metabase: http://localhost:3000
   - Prefect: http://localhost:4200

### "I need help"

1. Check `backups\` folder for recent backups
2. Review git history: `git log` to see what changed
3. Read this document again carefully
4. Use restore scripts - they have safety checks built-in

---

## ✅ Validation Checklist

Run this after any changes:

```batch
# 1. Check services running
docker-compose ps
# All should show "Up" status

# 2. Check volumes exist
docker volume ls
# Should see: postgres_data, n8n_data, prefect_data, airbyte_data

# 3. Test PostgreSQL
docker exec postgres pg_isready -U admin
# Should say "accepting connections"

# 4. Create test backup
cd scripts
backup.bat
# Should complete successfully

# 5. Verify services accessible
# - n8n: http://localhost:5678 (workflows visible?)
# - Metabase: http://localhost:3000 (dashboards visible?)
# - Prefect: http://localhost:4200 (flows visible?)
```

---

**Last Updated:** November 8, 2025  
**System Version:** With comprehensive backup/recovery  
**Protection Level:** Maximum

