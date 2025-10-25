# 🚀 Self-Hosted Analytics & Automation Platform

A lean, powerful stack combining PostgreSQL, n8n, and Metabase for personal analytics and automation needs.

## 📦 What's Included

- **PostgreSQL 16** - Central database for all services and your data
- **n8n** - Workflow automation and data integration
- **Metabase** - Business intelligence and analytics

## 🔒 Security Notice

**This stack is configured for secure local use:**

- ✅ All services bound to `localhost` (127.0.0.1) only
- ✅ Not accessible from other computers on your network
- ✅ Not accessible from the internet
- ✅ Requires configuration changes for remote access

**For detailed security information, see [SECURITY.md](SECURITY.md)**

## 🎯 Architecture

```
┌─────────────────────────────────────────────┐
│         Analytics & Automation Stack        │
├─────────────────────────────────────────────┤
│                                             │
│       ┌──────────┐      ┌──────────┐       │
│       │   n8n    │      │ Metabase │       │
│       │  :5678   │      │  :3000   │       │
│       └─────┬────┘      └─────┬────┘       │
│             │                 │             │
│             └────────┬────────┘             │
│                      │                      │
│              ┌───────▼────────┐             │
│              │   PostgreSQL   │             │
│              │     :5432      │             │
│              │   user: admin  │             │
│              │                │             │
│              │ • analytics_db │             │
│              │ • n8n_db       │             │
│              │ • metabase_app │             │
│              └────────────────┘             │
│                                             │
└─────────────────────────────────────────────┘
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

2. **Configure environment variables** (Recommended)
   
   Copy the example environment file:
   ```bash
   # Windows
   copy .env.example .env
   
   # Linux/Mac
   cp .env.example .env
   ```
   
   Edit `.env` and set strong passwords:
   - `POSTGRES_PASSWORD` - Your PostgreSQL master password
   - `MB_ENCRYPTION_SECRET_KEY` - Metabase encryption key (generate with: `openssl rand -hex 16`)
   - `N8N_ENCRYPTION_KEY` - n8n encryption key (generate with: `openssl rand -hex 16`)
   
   **Note:** The stack will work with default values for localhost-only use, but you should change them for security.

3. **Create desktop shortcuts** (Windows only)
   - Double-click `create-shortcuts.bat` 
   - This creates 3 shortcuts on your desktop for easy access

4. **Start the stack** - Double-click `start.bat` (or the desktop shortcut)
   - Or run: `docker-compose up -d`

5. **Check status** - Double-click `status.bat` (or the desktop shortcut)
   - Or run: `docker-compose ps`

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
  
- **PostgreSQL** (via DBeaver or any SQL client):
  - ⚠️ Only accessible from this computer (localhost-only)
  - Host: `localhost` or `127.0.0.1`
  - Port: `5432`
  - User: `admin`
  - Password: (from .env or default)
  - Databases: `analytics_db`, `n8n_db`, `metabase_app`

**Need remote access?** See the "Remote Access Options" section below or [SECURITY.md](SECURITY.md) for secure methods.

## 📊 Usage Examples

### Connect Metabase to Your Analytics Database

1. Open Metabase (http://localhost:3000)
2. Add database connection:
   - **Type**: PostgreSQL
   - **Host**: `postgres_main`
   - **Port**: `5432`
   - **Database**: `analytics_db`
   - **Username**: `admin`
   - **Password**: (from .env or default)

### Create n8n Workflow to Populate Database

1. Open n8n (http://localhost:5678)
2. Create new workflow
3. Add "PostgreSQL" node
4. Configure connection:
   - **Host**: `postgres_main`
   - **Database**: `analytics_db`
   - **User**: `admin`
   - **Password**: (from .env or default)
   - **Port**: `5432`
   - **SSL Mode**: `disable` (for local)

### Example: API → n8n → PostgreSQL → Metabase

```
[External API]
      ↓
  [n8n Workflow]
      ↓ (transforms data)
[PostgreSQL analytics_db.processed]
      ↓ (queries)
  [Metabase Dashboard]
```

## 🛠️ Management Commands

### Easy Windows Scripts (Just Double-Click!)

- **`create-shortcuts.bat`** - Create desktop shortcuts for easy access (run once)
- **`start.bat`** - Start all services
- **`stop.bat`** - Stop all services  
- **`restart.bat`** - Restart all services
- **`update.bat`** - Update to latest versions and restart
- **`status.bat`** - Check what's running
- **`logs.bat`** - View live logs (Ctrl+C to exit)
- **`backup.bat`** - Backup all PostgreSQL databases

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
docker exec -it postgres_main psql -U admin -d analytics_db

# Create backup (Windows PowerShell)
docker exec postgres_main pg_dump -U admin analytics_db > ./backups/backup_$(Get-Date -Format "yyyyMMdd_HHmmss").sql

# Restore backup
docker exec -i postgres_main psql -U admin -d analytics_db < ./backups/backup_20231020_120000.sql

# Backup all databases (Windows PowerShell)
docker exec postgres_main pg_dumpall -U admin > ./backups/full_backup_$(Get-Date -Format "yyyyMMdd_HHmmss").sql

# List all databases
docker exec -it postgres_main psql -U admin -c "\l"
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

- `postgres:16.4-alpine`
- `n8nio/n8n:1.63.4`
- `metabase/metabase:v0.51.2`

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
docker exec postgres_main pg_isready -U streamline_user

# Check database exists
docker exec -it postgres_main psql -U streamline_user -d streamline_db -c "\l"
```

### n8n workflows timing out

- Increase EXECUTIONS_DATA_MAX_AGE in docker-compose.yml
- Check n8n logs: `docker-compose logs n8n`
- Verify database connection in n8n settings

### Metabase slow performance

- Increase JAVA_OPTS memory allocation
- Check database query performance
- Review Metabase logs for errors

## 🔄 Backup Strategy

### Automated Daily Backup Script

Create `backup.bat`:

```batch
@echo off
docker exec postgres_main pg_dumpall -U admin > ./backups/backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.sql
echo Backup complete!
```

Schedule with Windows Task Scheduler to run daily.

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

## 📚 Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Metabase Documentation](https://www.metabase.com/docs/latest/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

## 📝 Notes

- All data persists in Docker volumes
- Services communicate via internal network (`stack-net`)
- Shared files go in `./shared/` directory
- Database backups go in `./backups/` directory
- Logs automatically rotate (max 10MB × 3 files)

## 🎯 Next Steps

1. Configure automated backups
2. Set up your first n8n workflow
3. Create Metabase dashboards
4. Consider adding reverse proxy for SSL
5. Set up monitoring (optional: Grafana + Prometheus)

---

**Enjoy your analytics platform! 🎉**

