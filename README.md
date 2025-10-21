# 🚀 Self-Hosted Analytics & Automation Platform

A lean, powerful stack combining PostgreSQL, n8n, and Metabase for personal analytics and automation needs.

## 📦 What's Included

- **PostgreSQL 16** - Central database for all services and your data
- **n8n** - Workflow automation and data integration
- **Metabase** - Business intelligence and analytics

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

2. **Optional: Set PostgreSQL password**
   - Create `.env` file with: `POSTGRES_PASSWORD=your_secure_password`
   - Or use default: `change_me_strong` (change in production!)

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
  - Create your account on first visit
  - Credentials stored in PostgreSQL
  
- **Metabase**: http://localhost:3000
  - Complete setup wizard
  - Connect to `postgres_main:5432` for analytics
  
- **PostgreSQL** (via DBeaver or any SQL client):
  - Host: `localhost`
  - Port: `5432`
  - User: `admin`
  - Password: (from .env or default `change_me_strong`)
  - Databases: `analytics_db`, `n8n_db`, `metabase_app`

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

1. **Change default passwords** in `.env` before first run
2. **Use strong passwords** (20+ characters, mixed case, numbers, symbols)
3. **Restrict network access** if exposing to internet
4. **Regular backups** - schedule daily backups
5. **Update regularly** - `docker-compose pull && docker-compose up -d`
6. **Monitor logs** - check for suspicious activity
7. **Use reverse proxy** (Traefik/Nginx) with SSL for external access

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

## 🌐 External Access (Optional)

For secure external access, consider:

1. **Cloudflare Tunnel** (free, recommended)
2. **Tailscale** (free for personal use)
3. **Nginx Reverse Proxy** with Let's Encrypt SSL
4. **Traefik** with automatic HTTPS

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

