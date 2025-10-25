# 🔒 Security Guidelines

This document outlines the security model, best practices, and configuration options for the Self-Hosted Analytics Stack.

## 🎯 Security Model Overview

This stack is designed with a **localhost-first security model**:

- **Default Configuration**: All services are bound to `127.0.0.1` (localhost only)
- **Network Isolation**: Services communicate internally via Docker network
- **No External Exposure**: By default, nothing is accessible from outside your computer
- **Progressive Security**: Works securely out-of-the-box, but requires configuration for internet exposure

## 🛡️ Threat Model & Assumptions

### What This Configuration Protects Against

✅ **Network-based attacks** from external sources  
✅ **Unauthorized access** from other computers on your network  
✅ **Accidental exposure** of database ports to the internet  
✅ **Credential theft** via network sniffing (when using localhost only)

### What This Configuration Does NOT Protect Against

❌ **Malicious software** running on your computer (has localhost access)  
❌ **Physical access** to your computer  
❌ **Compromised user account** on your computer  
❌ **Weak passwords** you might choose for web interfaces

### Assumptions

This stack assumes:
- You trust software running on your local computer
- Your computer itself is reasonably secure (updated OS, antivirus, etc.)
- You're running this for personal/development use on a trusted machine
- You'll follow security best practices when exposing services externally

## 🔐 Default Security Features

### Network Binding

All services are bound to localhost only:

```yaml
ports:
  - "127.0.0.1:5432:5432"  # PostgreSQL
  - "127.0.0.1:5678:5678"  # n8n
  - "127.0.0.1:3000:3000"  # Metabase
```

**What this means:**
- Services are accessible via `http://localhost:PORT` or `http://127.0.0.1:PORT`
- NOT accessible via `http://your-ip:PORT` from other devices
- NOT accessible from the internet without additional configuration

### Environment Variables & Secrets

The stack uses environment variables for sensitive configuration:

- `POSTGRES_PASSWORD` - Database master password
- `MB_ENCRYPTION_SECRET_KEY` - Metabase data encryption key
- `N8N_ENCRYPTION_KEY` - n8n credentials encryption key

**Default behavior:**
- Ships with obvious placeholder values (`INSECURE_DEFAULT_CHANGE_ME`)
- Works out-of-the-box for localhost testing
- Should be changed before any production use or external exposure

### Version Pinning

All Docker images use specific version tags (not `:latest`):
- Prevents unexpected breaking changes
- Makes deployments reproducible
- Allows controlled upgrade schedule

## ⚙️ Security Configuration

### Initial Setup (Recommended)

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Generate strong secrets:**
   
   **Windows PowerShell:**
   ```powershell
   # Generate a 32-character random string
   -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | % {[char]$_})
   ```
   
   **Linux/Mac:**
   ```bash
   openssl rand -hex 32
   ```

3. **Edit `.env` and replace all values:**
   ```
   POSTGRES_PASSWORD=<your-strong-password-here>
   MB_ENCRYPTION_SECRET_KEY=<your-random-key-here>
   N8N_ENCRYPTION_KEY=<your-random-key-here>
   ```

4. **Set appropriate file permissions (Linux/Mac):**
   ```bash
   chmod 600 .env
   ```

### For Localhost-Only Use

If you're only accessing services from your computer:

✅ **You can use default passwords** (but still not recommended)  
✅ **Services are reasonably secure** due to localhost binding  
⚠️ **Change passwords if others use your computer**

### For Network/Internet Exposure

If you need to access services from other devices or the internet:

🚨 **CRITICAL:** You MUST:
1. Set strong, unique passwords for all services
2. Use HTTPS (see reverse proxy section)
3. Implement additional authentication/authorization
4. Consider using a VPN or secure tunnel (see options below)

## 🌐 Remote Access Options

### Option 1: SSH Tunnel (Most Secure)

Access services remotely via SSH tunnel without exposing ports:

```bash
# On your local machine (remote location)
ssh -L 3000:127.0.0.1:3000 user@your-server.com
ssh -L 5678:127.0.0.1:5678 user@your-server.com
```

Then access via `http://localhost:3000` and `http://localhost:5678` on your remote machine.

**Pros:** Very secure, uses existing SSH infrastructure  
**Cons:** Requires SSH access, must set up for each session

### Option 2: Cloudflare Tunnel (Easy & Free)

Securely expose services via Cloudflare without opening ports:

1. Sign up for Cloudflare (free tier available)
2. Install `cloudflared` on your server
3. Configure tunnel to forward to localhost ports
4. Access via custom domain with automatic HTTPS

**Pros:** Free, automatic HTTPS, no firewall changes  
**Cons:** Requires Cloudflare account, adds external dependency

Resources: [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

### Option 3: Tailscale (Private Network)

Create a private network between your devices:

1. Install Tailscale on host and client devices
2. Access services using Tailscale IP
3. No configuration changes needed to docker-compose

**Pros:** Easy setup, works like a VPN, very secure  
**Cons:** Requires Tailscale on all devices

Resources: [Tailscale Documentation](https://tailscale.com/kb/)

### Option 4: Reverse Proxy with HTTPS (Advanced)

Use Nginx, Traefik, or Caddy as a reverse proxy:

**Not recommended for beginners** - requires significant configuration for security.

If you choose this path:
1. Set up reverse proxy with automatic HTTPS (Let's Encrypt)
2. Configure authentication (basic auth, OAuth, etc.)
3. Update `docker-compose.yml` to expose ports to reverse proxy
4. Set security headers (HSTS, CSP, etc.)

## 🔄 Rotating Secrets & Passwords

### Rotating POSTGRES_PASSWORD

1. Stop the stack: `docker-compose down`
2. Update password in `.env` file
3. Connect to Postgres container: `docker-compose up -d postgres`
4. Change password: 
   ```sql
   docker exec -it postgres_main psql -U admin -c "ALTER USER admin WITH PASSWORD 'new_password';"
   ```
5. Start other services: `docker-compose up -d`

### Rotating Encryption Keys

⚠️ **WARNING:** Changing encryption keys will make existing encrypted data unreadable!

**For MB_ENCRYPTION_SECRET_KEY:**
- Once Metabase has encrypted data, changing this key will break access
- Only change if you're willing to reconfigure all database connections

**For N8N_ENCRYPTION_KEY:**
- Once n8n has stored credentials, changing this key will break all workflows
- You'll need to re-enter all credentials in workflows

**Safe approach:**
1. Export/backup all configurations and credentials
2. Change the encryption key
3. Re-import/reconfigure everything

## 💾 Backup Security

### Backup Best Practices

1. **Encrypt backups** if storing off-site:
   ```bash
   # Create encrypted backup
   docker exec postgres_main pg_dumpall -U admin | gpg --symmetric --cipher-algo AES256 > backup_encrypted.sql.gpg
   ```

2. **Store backups securely:**
   - Use encrypted cloud storage (AWS S3 with encryption, etc.)
   - Keep multiple versions
   - Store in different physical locations

3. **Test restore procedures regularly:**
   ```bash
   # Test restore (on test database)
   docker exec -i postgres_main psql -U admin -d test_db < backup.sql
   ```

4. **Automate backups:**
   - Schedule `backup.bat` with Windows Task Scheduler
   - Or use `cron` on Linux

### Backup Files Security

The `./backups/` directory contains sensitive data:
- Already in `.gitignore` (not committed to version control)
- Contains complete database dumps with all data
- Should have restricted file permissions (Windows: limit to your user)

## 🔍 Security Checklist

### Before First Use
- [ ] Copy `.env.example` to `.env`
- [ ] Generate and set strong `POSTGRES_PASSWORD`
- [ ] Generate and set `MB_ENCRYPTION_SECRET_KEY`
- [ ] Generate and set `N8N_ENCRYPTION_KEY`
- [ ] Verify services only accessible on localhost

### Before Internet Exposure
- [ ] All secrets changed from defaults
- [ ] HTTPS configured (reverse proxy or tunnel)
- [ ] Additional authentication configured
- [ ] Firewall rules reviewed
- [ ] Backup strategy implemented
- [ ] Monitoring/logging configured

### Regular Maintenance
- [ ] Update Docker images regularly (check for security patches)
- [ ] Review access logs for suspicious activity
- [ ] Test backup restore procedures
- [ ] Audit n8n workflows for security issues
- [ ] Check Metabase database permissions

## 🚨 Security Incident Response

If you suspect a security breach:

1. **Immediate actions:**
   - Stop the stack: `docker-compose down`
   - Disconnect from network if necessary
   - Review logs: `docker-compose logs`

2. **Investigation:**
   - Check who accessed services: Review Metabase/n8n logs
   - Check database logs: `docker logs postgres_main`
   - Review system logs for unauthorized access

3. **Remediation:**
   - Change all passwords and secrets
   - Review and update access controls
   - Restore from known-good backup if necessary
   - Update to latest versions with security patches

4. **Prevention:**
   - Document what happened
   - Update security measures
   - Implement additional monitoring

## 📚 Additional Resources

- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [PostgreSQL Security Guide](https://www.postgresql.org/docs/current/security.html)
- [n8n Security Documentation](https://docs.n8n.io/hosting/security/)
- [Metabase Security Guide](https://www.metabase.com/learn/administration/metabase-security)

## 📝 Questions or Issues?

If you discover a security vulnerability, please:
1. **Do not** open a public GitHub issue
2. Contact the maintainer directly
3. Allow reasonable time for a fix before public disclosure

---

**Remember:** Security is a process, not a destination. Regularly review and update your security practices.

