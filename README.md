# Self-Hosted Analytics

Personal analytics stack I use to track real-world data: finances,
investments, job search, fitness. Postgres, n8n, Prefect, and Metabase
in one `docker compose up`.

## Quick start

```bash
git clone https://github.com/mumtazm1/self-hosted-analytics.git
cd self-hosted-analytics
./install.sh
```

The installer generates secrets, starts everything, waits for
healthchecks, and prints URLs. Takes about 3 minutes on a fresh machine.

**Requirements:** Docker 20.10+, `docker compose` v2, `openssl`, 4 GB RAM,
10 GB disk.

## What's in the stack

| Service    | Purpose                        | URL                     |
|------------|--------------------------------|-------------------------|
| Postgres   | Central database               | `localhost:5432`        |
| n8n        | Workflow automation / ETL      | http://localhost:5678   |
| Metabase   | Dashboards and exploration     | http://localhost:3000   |
| Prefect    | Scheduled Python pipelines     | http://localhost:4200   |

All services bind to `127.0.0.1` only. Nothing exposed to the network
or internet. See [`docs/SECURITY.md`](docs/SECURITY.md) for remote
access options.

n8n and Prefect store state in Postgres (same cluster, separate
databases), so one `pg_dump` captures everything.

## Upgrading from an earlier version

Volume names changed in the latest release. If you were already
running this stack, **do not just `git pull && docker compose up -d`**.
See [`UPGRADING.md`](UPGRADING.md) for the two supported upgrade paths.

## Day-to-day

```bash
./scripts/start.sh          # start
./scripts/stop.sh           # stop
./scripts/status.sh         # check status
./scripts/logs.sh           # tail logs
./scripts/backup.sh         # back up everything
./scripts/restore-all.sh    # restore from backup
./scripts/update.sh         # pull new images, restart
```

On Windows, run these via WSL2 or Git Bash (both come with Docker Desktop).

## Backups

`backup.sh` creates a timestamped `pg_dump` of every database plus
volume backups for n8n and Prefect. `restore-all.sh` reverses it.
See [`docs/DATA_PROTECTION.md`](docs/DATA_PROTECTION.md).

Volumes are named and scoped to the project. `docker compose down` keeps
them; only `docker compose down -v` deletes them.

## Configuration

`install.sh` writes a `.env` with a random Postgres password and n8n
encryption key on first run. Delete `.env` and re-run to rotate secrets.

See [`docs/SECURITY.md`](docs/SECURITY.md) for timezone, custom domain,
and reverse-proxy settings.

## Contributing

PRs welcome. Useful contributions right now:

1. More examples in `examples/` - any real pipeline you've built
2. OS testing - installer verified on Ubuntu/Debian; macOS and WSL2
   should work but aren't in CI yet
3. Metabase dashboard templates as importable JSON

## License

MIT. See [LICENSE](LICENSE).
