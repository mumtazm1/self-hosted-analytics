# 🚀 Self-Hosted Analytics & Automation Platform

A lean, powerful stack combining PostgreSQL, n8n, Metabase, and Prefect for personal analytics and automation needs.

## 🛡️ **Data Protection Built-In**

This stack is designed to **NEVER lose your data:**
- ✅ All volumes marked as `external: true` (protected from accidental deletion)
- ✅ Comprehensive backup system (PostgreSQL + n8n SQLite + Prefect volumes)
- ✅ Automated restore scripts for disaster recovery
- ✅ Configuration locked in `.env` file to prevent breaking changes
- ✅ Organized `scripts/` folder for easy maintenance

## 📦 What's Included

| Service | Purpose | Access URL | Port |
|---------|---------|------------|------|
| **PostgreSQL 16** | Central database for all services | localhost:5432 | 5432 |
| **n8n** | Workflow automation & data integration | http://localhost:5678 | 5678 |
| **Metabase** | Business intelligence & analytics | http://localhost:3000 | 3000 |
| **Prefect** | Workflow orchestration & scheduling | http://localhost:4200 | 4200 |
| **Airbyte** | Data integration platform (optional - see setup) | http://localhost:8000 | 8000 |

## 🔒 Security Notice

**This stack is configured for secure local use:**

- ✅ All services bound to `localhost` (127.0.0.1) only
- ✅ Not accessible from other computers on your network
- ✅ Not accessible from the internet
- ✅ Requires configuration changes for remote access

**For detailed security information, see [SECURITY.md](SECURITY.md)**

## 🎯 Architecture

```
┌──────────────────────────────────────────────────────┐
│         Analytics & Automation Stack                 │
├──────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │   n8n    │  │ Metabase │  │ Prefect  │            │
│  │  :5678   │  │  :3000   │  │  :4200   │            │
│  └─────┬────┘  └─────┬────┘  └─────┬────┘            │
│        │             │             │                 │
│        └─────────────┼─────────────┘                 │
│                      │                               │
│              ┌───────▼────────┐                      │
│              │   PostgreSQL   │                      │
│              │     :5432      │                      │
│              │   user: admin  │                      │
│              │                │                      │
│              │ • analytics    │ (your data)          │
│              │ • n8n          │ (workflows)          │
│              │ • metabase     │ (BI metadata)        │
│              │ • prefect      │ (orchestration)      │
│              └────────────────┘                      │
│                                                      │
│  All services: localhost only (127.0.0.1)            │
└──────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Docker Desktop (includes Docker Engine & Compose)
- At least 4GB RAM available
- 10GB free disk space

### Initial Setup

1. **Create required directories** (if they don't exist)
   ```bash
   mkdir shared backups
   ```

2. **Configure environment variables** (Already created)
   
   A `.env` file has been created with secure defaults.
   To change passwords or settings:
   - Edit `.env` file in the root directory
   - Restart services: `docker-compose restart`
   
   **Note:** Configuration is locked to prevent accidental changes. Only modify if you know what you're doing!

3. **Create desktop shortcuts** (Windows only)
   - Double-click `scripts\create-shortcuts.bat` 
   - This creates 3 shortcuts on your desktop for easy access

4. **Start the stack** - Double-click the "Analytics Stack - Start" desktop shortcut
   - Or run from `scripts\` folder: `start.bat`
   - Or run: `docker-compose up -d` from project root

5. **Check status** - Double-click the "Analytics Stack - Status" desktop shortcut
   - Or run from `scripts\` folder: `status.bat`
   - Or run: `docker-compose ps` from project root

### First-Time Access

After containers are running (give it 2-3 minutes):

- **n8n**: http://localhost:5678
  - ⚠️ Only accessible from this computer (localhost-only)
  - Create your account on first visit
  - Credentials stored in PostgreSQL
  
- **Metabase**: http://localhost:3000
  - ⚠️ Only accessible from this computer (localhost-only)
  - Complete setup wizard
  - Connect to `postgres_main:5432` for analytics
  
- **Prefect**: http://localhost:4200
  - ⚠️ Only accessible from this computer (localhost-only)
  - Create and schedule workflows
  - Monitor workflow runs in the UI
  
- **PostgreSQL** (via DBeaver or any SQL client):
  - ⚠️ Only accessible from this computer (localhost-only)
  - Host: `localhost` or `127.0.0.1`
  - Port: `5432`
  - User: `admin`
  - Password: (from .env or default)
  - Databases: `analytics`, `n8n`, `metabase`, `prefect`

**Need remote access?** See the "Remote Access Options" section below or [SECURITY.md](SECURITY.md) for secure methods.

## 📊 Usage Examples

### Using Prefect for Workflow Orchestration

1. Open Prefect UI (http://localhost:4200)
2. Create a simple Python flow:
   ```python
   from prefect import flow, task
   
   @task
   def fetch_data():
       # Your data fetching logic
       return {"data": "example"}
   
   @task
   def process_data(data):
       # Process and transform data
       return data
   
   @flow
   def my_workflow():
       data = fetch_data()
       result = process_data(data)
       return result
   
   if __name__ == "__main__":
       my_workflow()
   ```

3. Deploy to Prefect server:
   ```bash
   prefect deploy
   ```

### Connect Metabase to Your Analytics Database

1. Open Metabase (http://localhost:3000)
2. Add database connection:
   - **Type**: PostgreSQL
   - **Host**: `postgres`
   - **Port**: `5432`
   - **Database**: `analytics`
   - **Username**: `admin`
   - **Password**: (from .env)

### Create n8n Workflow to Populate Database

1. Open n8n (http://localhost:5678)
2. Create new workflow
3. Add "PostgreSQL" node
4. Configure connection:
   - **Host**: `postgres`
   - **Database**: `analytics`
   - **User**: `admin`
   - **Password**: (from .env)
   - **Port**: `5432`
   - **SSL Mode**: `disable` (for local)

### Example Workflows

**Option 1: n8n for Simple Automation**
```
[External API] → [n8n Workflow] → [PostgreSQL analytics.data] → [Metabase Dashboard]
```

**Option 2: Prefect for Complex Orchestration**
```
[Prefect Flow] → [Python Tasks] → [PostgreSQL analytics.data] → [Metabase Dashboard]
                      ↓
              [n8n for Notifications]
```

## 🛠️ Management Commands

### Easy Windows Scripts (in `scripts/` folder)

**Maintenance Scripts:**
- **`scripts\start.bat`** - Start all services
- **`scripts\stop.bat`** - Stop all services  
- **`scripts\restart.bat`** - Restart all services
- **`scripts\update.bat`** - Update to latest versions and restart
- **`scripts\status.bat`** - Check what's running
- **`scripts\logs.bat`** - View live logs (Ctrl+C to exit)

**Backup & Recovery:**
- **`scripts\backup.bat`** - **NEW!** Comprehensive backup (PostgreSQL + all volumes)
- **`scripts\restore\restore-postgres.bat`** - Restore PostgreSQL databases
- **`scripts\restore\restore-n8n.bat`** - Restore n8n workflows & credentials
- **`scripts\restore\restore-all.bat`** - Full disaster recovery

**Setup:**
- **`scripts\create-shortcuts.bat`** - Create desktop shortcuts (run once)

### Manual Commands (Alternative)

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ deletes data)
docker-compose down -v

# View logs
docker-compose logs -f
docker-compose logs -f n8n
docker-compose logs -f metabase
docker-compose logs -f postgres

# Restart a specific service
docker-compose restart n8n
docker-compose restart metabase

# Update images
docker-compose pull
docker-compose up -d
```

### Database Management

```bash
# Access PostgreSQL CLI
docker exec -it postgres psql -U admin -d analytics

# Create backup (Windows PowerShell)
docker exec postgres pg_dump -U admin analytics > ./backups/backup_$(Get-Date -Format "yyyyMMdd_HHmmss").sql

# Restore backup
docker exec -i postgres psql -U admin -d analytics < ./backups/backup_20231020_120000.sql

# Backup all databases (Windows PowerShell)
docker exec postgres pg_dumpall -U admin > ./backups/full_backup_$(Get-Date -Format "yyyyMMdd_HHmmss").sql

# List all databases
docker exec -it postgres psql -U admin -c "\l"
```

### Monitoring

```bash
# Check resource usage
docker stats

# Check disk usage
docker system df

# Inspect network
docker network inspect self_hosted_analytics_stack-net
```

## 🔒 Security Best Practices

### For Localhost-Only Use (Default)

✅ **Already secure:** Services bound to localhost only  
✅ **Basic passwords OK:** Not exposed to network  
⚠️ **Still recommended:** Set strong passwords in `.env` file

### For Remote Access or Internet Exposure

🚨 **CRITICAL - You MUST:**

1. **Set strong passwords** in `.env` file (20+ characters, mixed case, numbers, symbols)
2. **Use secure tunneling** (SSH, Cloudflare Tunnel, Tailscale) - see [SECURITY.md](SECURITY.md)
3. **Enable HTTPS** if using reverse proxy
4. **Regular backups** - schedule `backup.bat` with Task Scheduler
5. **Update regularly** - `docker-compose pull && docker-compose up -d`
6. **Monitor logs** - check for suspicious activity

**For detailed security guidance, see [SECURITY.md](SECURITY.md)**

## 📈 Performance Tuning

### For More RAM (8GB+)

Edit `docker-compose.yml`:

```yaml
# PostgreSQL
POSTGRES_SHARED_BUFFERS: 512MB
POSTGRES_EFFECTIVE_CACHE_SIZE: 2GB

# Metabase
JAVA_OPTS: -Xmx2g -Xms1g
```

### For Limited RAM (4GB)

```yaml
# Metabase
JAVA_OPTS: -Xmx512m -Xms256m

# Reduce resource limits across all services
```

## 🔄 Upgrading Docker Images

This stack uses **pinned versions** for stability and security:

- `postgres:16-alpine` (pinned to major version 16)
- `n8nio/n8n:1.115.3`
- `metabase/metabase:latest` (update as needed)

### How to Upgrade

1. **Backup first!** Run `backup.bat`

2. **Check for updates:**
   - [PostgreSQL releases](https://hub.docker.com/_/postgres/tags?page=1&name=16)
   - [n8n releases](https://hub.docker.com/r/n8nio/n8n/tags)
   - [Metabase releases](https://hub.docker.com/r/metabase/metabase/tags)

3. **Update versions in `docker-compose.yml`:**
   ```yaml
   image: postgres:16.5-alpine  # Update version number
   ```

4. **Apply updates:**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

5. **Verify everything works:**
   ```bash
   docker-compose ps
   docker-compose logs
   ```

⚠️ **Note:** Major version upgrades (e.g., Postgres 16 → 17) may require data migration. Always backup first!

## 📋 Environment Variable Reference

All configuration is managed via the `.env` file. Copy `.env.example` to `.env` and customize:

### Database Connection
| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_HOST` | `postgres` | PostgreSQL container hostname |
| `POSTGRES_PORT` | `5432` | PostgreSQL port |
| `POSTGRES_USER` | `admin` | Database superuser |
| `POSTGRES_PASSWORD` | ⚠️ Required | Master database password |

### Database Names
| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_DB` | `analytics` | Main analytics database |
| `POSTGRES_N8N_DB` | `n8n` | n8n workflow database |
| `POSTGRES_METABASE_DB` | `metabase` | Metabase app database |
| `POSTGRES_PREFECT_DB` | `prefect` | Prefect orchestration database |

### Other Settings
| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | `UTC` | Timezone for all services |
| `N8N_PROTOCOL` | `http` | Protocol for n8n webhooks |
| `N8N_HOST` | `localhost` | Hostname for n8n |
| `WEBHOOK_URL` | `http://localhost:5678` | n8n webhook URL |
| `MB_SITE_URL` | `http://localhost:3000` | Metabase site URL |
| `PREFECT_API_URL` | `http://localhost:4200/api` | Prefect API URL |

**Note:** All services share the same PostgreSQL credentials for simplicity. For advanced use cases, you can create separate database users with limited permissions.

## 🐛 Troubleshooting

### Services won't start

```bash
# Check logs
docker-compose logs

# Verify ports aren't in use
netstat -ano | findstr "5432 5678 3000 5050"

# Reset everything (⚠️ loses data)
docker-compose down -v
docker-compose up -d
```

### Database connection errors

```bash
# Check if postgres is healthy
docker-compose ps postgres

# Test connection
docker exec postgres pg_isready -U admin

# Check database exists
docker exec -it postgres psql -U admin -d analytics -c "\l"
```

### n8n workflows timing out

- Increase EXECUTIONS_DATA_MAX_AGE in docker-compose.yml
- Check n8n logs: `docker-compose logs n8n`
- Verify database connection in n8n settings

### Metabase slow performance

- Increase JAVA_OPTS memory allocation
- Check database query performance
- Review Metabase logs for errors

## 🔄 Comprehensive Backup & Recovery System

### What Gets Backed Up

The `scripts\backup.bat` script backs up **EVERYTHING**:

1. **PostgreSQL databases** - Metabase, Prefect, Airbyte, Analytics (SQL dump)
2. **n8n workflows & credentials** - SQLite database and files (tar.gz)
3. **Prefect local data** - Flow storage and metadata (tar.gz)
4. **Airbyte configurations** - When enabled (tar.gz)

### Creating Backups

**Run backup manually:**
```batch
cd scripts
backup.bat
```

**Schedule automated backups** (Windows Task Scheduler):
1. Open Task Scheduler
2. Create Basic Task → Daily
3. Action: Start a program
4. Program: `C:\Users\YourUser\Projects\self-hosted-analytics\scripts\backup.bat`

### Restoring from Backup

**Restore specific service:**
```batch
cd scripts\restore
restore-postgres.bat    # Restore Metabase dashboards, Prefect flows
restore-n8n.bat         # Restore n8n workflows and credentials
```

**Full disaster recovery:**
```batch
cd scripts\restore
restore-all.bat         # Restores everything
```

### Why You Won't Lose Data Anymore

1. **External volumes** - Marked `external: true` in docker-compose.yml
   - Won't be deleted by `docker-compose down -v`
   - Persist across container recreation
   
2. **Comprehensive backups** - All data sources backed up
   - PostgreSQL dumps capture Metabase, Prefect, Airbyte
   - Volume backups capture n8n SQLite database
   
3. **Easy recovery** - Simple scripts to restore any component
   - Tested restore procedures
   - Step-by-step recovery guides
   
4. **Configuration lock** - `.env` file prevents accidental changes
   - Services won't start with wrong database settings
   - Clear defaults documented

## 🌐 Remote Access Options

By default, services are **only accessible from your computer**. To access from other devices:

### Recommended Methods

1. **SSH Tunnel** (Most Secure)
   ```bash
   ssh -L 3000:127.0.0.1:3000 user@your-server
   ```
   Then access via `http://localhost:3000` on remote machine

2. **Cloudflare Tunnel** (Easy & Free)
   - Automatic HTTPS
   - No firewall changes needed
   - [Setup Guide](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

3. **Tailscale** (Private Network)
   - Create secure network between devices
   - [Setup Guide](https://tailscale.com/kb/)

4. **Reverse Proxy** (Advanced)
   - Nginx or Traefik with Let's Encrypt
   - Requires significant security configuration
   - Only recommended for experienced users

⚠️ **Security Warning:** Before exposing to internet:
- Set strong passwords in `.env`
- Enable HTTPS
- Read [SECURITY.md](SECURITY.md) thoroughly

**Need to temporarily expose Postgres for GUI tools?**
See [SECURITY.md](SECURITY.md) for safe methods.

## ➕ Adding Airbyte (Optional)

Airbyte is ready to add but requires their full stack (multiple containers). The database and volume are already prepared.

**To add Airbyte OSS:**

1. Download Airbyte's deployment script:
   ```bash
   curl -LO https://raw.githubusercontent.com/airbytehq/airbyte/master/run-ab-platform.sh
   chmod +x run-ab-platform.sh
   ```

2. Run Airbyte:
   ```bash
   ./run-ab-platform.sh -b
   ```

3. Access Airbyte at: http://localhost:8000

4. Configure Airbyte to use your PostgreSQL:
   - Host: `postgres`
   - Port: `5432`
   - Database: `airbyte` (already created)
   - User: `admin`
   - Password: (from .env file)

**Note:** The `airbyte_data` volume is already created and will be backed up by `scripts\backup.bat`.

## 📚 Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Metabase Documentation](https://www.metabase.com/docs/latest/)
- [Prefect Documentation](https://docs.prefect.io/)
- [Airbyte Documentation](https://docs.airbyte.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

## 📝 Notes

- All data persists in Docker volumes (marked `external: true` for protection)
- Services communicate via internal network (`stack-net`)
- Shared files go in `./shared/` directory
- Database backups go in `./backups/` directory
- All management scripts in `./scripts/` directory
- Logs automatically rotate (max 10MB × 3 files)
- n8n uses SQLite (not PostgreSQL) for maximum stability

## 🎯 Next Steps

1. ✅ **Backups configured** - Run `scripts\backup.bat` to test
2. Create your first n8n workflow
3. Build Metabase dashboards
4. Set up Prefect orchestration flows
5. (Optional) Add Airbyte for data integration
6. Schedule automated backups with Task Scheduler

---

**Enjoy your analytics platform! 🎉**

