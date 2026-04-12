# Upgrading

## From pre-`install.sh` revisions (anyone on `main` before the release-ready branch lands)

**Breaking change: volumes were renamed.**

Older revisions of this repo used globally-named external volumes:
`postgres_data`, `n8n_data`, `prefect_data`. This release renames them to
project-scoped named volumes: `${COMPOSE_PROJECT_NAME}_postgres_data` (and
so on), with `COMPOSE_PROJECT_NAME` defaulting to `sha` via `install.sh`.

**What will happen if you just `git pull && docker compose up -d`:**

Compose will create fresh, empty `sha_postgres_data` / `sha_n8n_data` /
`sha_prefect_data` volumes. Your old data (`postgres_data`, etc.) will
still be on disk, **but nothing will reference it**. The UI will look
empty. n8n workflows gone, Prefect deployments gone, Metabase questions
gone. The old volumes are still there and can be recovered, but a reader
who doesn't know that will think the upgrade wiped them out.

`install.sh` now detects this case and refuses to proceed unless you
explicitly pass `--fresh`. You have two supported paths.

---

## Path 1: Preserve your existing data

**Summary:** keep the old volumes as-is, create a small override file
that maps the new compose names to them, use the override from then on.

1. **Back up everything first** (belt and suspenders, never trust a
   migration you haven't backed up):

   ```bash
   ./scripts/backup.sh
   ```

2. **Create `docker-compose.upgrade.yml`** in the repo root:

   ```yaml
   services:
     postgres:
       volumes: !override
         - postgres_data:/var/lib/postgresql/data
         - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql:ro
         - ./backups:/backups
     n8n:
       volumes: !override
         - n8n_data:/home/node/.n8n
         - ./shared:/shared
     prefect:
       volumes: !override
         - prefect_data:/root/.prefect
         - ./shared:/shared

   volumes:
     postgres_data:
       external: true
     n8n_data:
       external: true
     prefect_data:
       external: true
   ```

   This tells compose to use the old globally-named volumes instead of
   creating new project-scoped ones.

3. **Run the installer, then always compose with the override:**

   ```bash
   ./install.sh --fresh
   # (the --fresh flag tells install.sh to ignore the old-volume
   #  warning; the override will redirect the new stack at them)
   docker compose stop
   docker compose -f docker-compose.yml -f docker-compose.upgrade.yml up -d
   ```

   From this point forward you must always pass
   `-f docker-compose.yml -f docker-compose.upgrade.yml` to any
   compose command, or alias it:

   ```bash
   alias sha-compose='docker compose -f docker-compose.yml -f docker-compose.upgrade.yml'
   ```

4. **Verify your data came back:** open n8n / Metabase / Prefect and
   check that your old workflows, dashboards, and flows are still there.

---

## Path 2: Start fresh and restore from a backup

**Summary:** take a `pg_dumpall` + volume backup first, wipe the old
volumes, install clean, restore.

1. **Back up everything** (this is the source of truth for the restore):

   ```bash
   ./scripts/backup.sh
   ```

   This writes three files into `./backups/`:
   - `backup_postgres_<timestamp>.sql`
   - `backup_n8n_<timestamp>.tar.gz`
   - `backup_prefect_<timestamp>.tar.gz`

2. **Stop anything currently running and remove the old volumes:**

   ```bash
   docker compose down
   docker volume rm postgres_data n8n_data prefect_data
   ```

3. **Install clean:**

   ```bash
   ./install.sh --fresh
   ```

4. **Restore from the backup files:**

   ```bash
   ./scripts/restore-all.sh
   ```

5. **Verify** the UIs look right and your data is back.

---

## Which path should you pick?

- **Path 1** if you want zero downtime and minimal risk. You never delete
  anything; worst case you revert the override and you're back where you
  started.
- **Path 2** if you want a clean break and you trust your backups. It's
  simpler to maintain long-term because there's no override file.

Path 1 is safer. Path 2 is cleaner.

## If something goes wrong

Neither path deletes the old globally-named volumes automatically. If
either path doesn't work, your old data is still on disk under
`postgres_data`, `n8n_data`, and `prefect_data`. You can inspect them
with:

```bash
docker volume inspect postgres_data
docker run --rm -v postgres_data:/d alpine ls -la /d
```

And you can always reset everything and try again.
