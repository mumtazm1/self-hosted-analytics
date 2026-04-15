# Upgrading

## From n8n 1.x to 2.x (April 2026)

This release bumps n8n from `1.121.3` to `2.15.1` and Metabase from
`v0.55.23` to `v0.59.6`. **The n8n jump is a major version bump (1.x →
2.x) with breaking changes.** Read this section before `git pull`.

**Back up first** (regardless of which path you take):

```bash
./scripts/backup.sh
```

### Breaking changes in n8n 2.x

1. **Base image is now "Docker Hardened Alpine".** The n8n image no
   longer ships `apk`, `apt-get`, or any package manager. If you had a
   custom Dockerfile that installed extra system packages via `apk add`,
   it will break. Use a multi-stage build to copy binaries from a
   standard Alpine image, or install packages via npm where possible.
   SSH client and Node.js are still pre-installed.

2. **Sub-workflow trigger type changed.** In 1.x, sub-workflows could
   use `n8n-nodes-base.manualTrigger` and still be called by an
   orchestrator workflow via the Execute Workflow node. In 2.x, any
   sub-workflow that's called by another workflow **must** use
   `n8n-nodes-base.executeWorkflowTrigger` instead — otherwise the
   parent workflow's Execute Workflow node will fail with "workflow is
   not callable."

   **What to do:** After upgrading, open each active sub-workflow in
   the n8n UI. If its trigger node is "When clicked" (manualTrigger),
   replace it with "When called by another workflow"
   (executeWorkflowTrigger). The top-level orchestrator workflow can
   keep `manualTrigger` since it's not called by anyone.

   Workflows that are not called by other workflows (standalone,
   scheduled, or webhook-triggered) are unaffected.

3. **Task runners are now external.** In 1.x, n8n's task runner ran
   in-process inside the n8n container. In 2.x it's a separate process.
   If you set `N8N_RUNNERS_ENABLED=true` (this repo's compose file does
   by default) nothing changes for you — n8n spawns the runner
   automatically.

4. **Environment variable access in Code nodes is blocked by default.**
   In 1.x, Code nodes could read `$env.MY_VAR` freely. In 2.x this is
   disabled as a security default. If your workflows depend on it, set
   `N8N_RUNNERS_ALLOW_ENV_VARS=true` in the n8n service's environment.

5. **The Execute Command node is disabled by default.** If any of your
   workflows shell out to local commands, you'll need to explicitly
   allow the node in your n8n settings or via environment variables.
   Most workflows don't use this node.

### Metabase v0.55 → v0.59

Metabase migrates its own schema automatically on first boot against
its metadata database. The first boot after the upgrade may take
several minutes as Metabase runs migrations on a ~4-minor-version jump
— watch the logs for "Metabase Initialization COMPLETE" before
considering the service ready. No manual migration steps are required.

### Recommended upgrade procedure

```bash
# 1. Back up
./scripts/backup.sh

# 2. Pull
git pull

# 3. Pull new images
docker compose pull n8n metabase

# 4. Recreate just n8n + metabase (Postgres, Prefect, Portainer untouched)
docker compose up -d --force-recreate n8n metabase

# 5. Watch logs until both services are ready
docker compose logs -f n8n
docker compose logs -f metabase

# 6. Fix any sub-workflow triggers flagged by n8n as not callable
#    (see breaking change #2 above)
```

If the upgrade goes wrong:

```bash
# Revert to previous version
git checkout <previous-commit> -- docker-compose.yml
docker compose up -d --force-recreate n8n metabase

# Or restore from backup
./scripts/restore-postgres.sh backups/<your-backup>.sql
./scripts/restore-n8n.sh backups/<your-n8n-backup>.tar.gz
```

---

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
