# Self-Hosted Analytics

A personal analytics stack for people who want to track their own real-world
data — finances, investments, job search, fitness, whatever — on infrastructure
they own. Postgres, n8n, Prefect, and Metabase in one `docker compose up`.

Built by [@mumtazm1](https://github.com/mumtazm1) for actual personal use. Not
a SaaS wrapper, not a multi-tenant platform, not a PostHog clone. Four
containers, wired correctly, with real backups and a one-command install.

> **Note:** This README's positioning is a working draft. It'll be replaced
> with Owais's own voice once he records a walkthrough. PRs welcome in the
> meantime.

## Quick start

```bash
git clone https://github.com/mumtazm1/self-hosted-analytics.git
cd self-hosted-analytics
./install.sh
```

That's it. The installer generates fresh secrets, brings up all four services,
waits for healthchecks, and prints URLs.

**Requirements:** Docker 20.10+, `docker compose` v2, `openssl`, 4 GB free RAM,
10 GB free disk.

## What's in the stack

| Service    | Purpose                        | URL                     |
|------------|--------------------------------|-------------------------|
| Postgres   | Central database for your data | `localhost:5432`        |
| n8n        | Workflow automation / ETL      | http://localhost:5678   |
| Metabase   | Dashboards and exploration     | http://localhost:3000   |
| Prefect    | Scheduled Python pipelines     | http://localhost:4200   |

All four bind to `127.0.0.1` only. Nothing is exposed to your network or the
internet by default. See [`docs/SECURITY.md`](docs/SECURITY.md) for how to open
it up safely if you want to.

n8n and Prefect both store their own state in Postgres (same cluster, separate
databases), so a single `pg_dump` captures everything.

## Examples

The stack is the plumbing. The real value is opinionated end-to-end examples
that turn empty infra into something useful on day one. See [`examples/`](examples/):

- **`examples/personal-finance/`** — pull transactions via n8n, land them in
  Postgres, explore with a pre-built Metabase dashboard. *(In progress — see
  the example's own README for what's wired up and what still needs a real
  pipeline.)*

If you've built your own pipeline on top of this stack, PRs for new examples
are welcome.

## Day-to-day

```bash
./scripts/linux/start.sh     # start everything
./scripts/linux/stop.sh      # stop everything
./scripts/linux/status.sh    # see what's running
./scripts/linux/logs.sh      # tail logs
./scripts/linux/backup.sh    # dump all databases to ./backups/
./scripts/linux/restore-all.sh  # restore from the latest backup
./scripts/linux/update.sh    # pull new images and restart
```

Windows `.bat` equivalents are in `scripts/windows/`.

## Backups and data safety

`backup.sh` writes a timestamped `pg_dump` of every database to `./backups/`
and also backs up n8n and Prefect volumes. `restore-all.sh` reverses it.
See [`docs/DATA_PROTECTION.md`](docs/DATA_PROTECTION.md).

The compose file uses named volumes scoped to the project name. `docker
compose down` will not delete them; only `docker compose down -v` will.

## Configuration

`install.sh` generates a `.env` file on first run with a random Postgres
password and n8n encryption key. It's `chmod 600` and gitignored. Delete it
and re-run `install.sh` to rotate secrets (you'll lose n8n credential storage
— re-enter your credentials in the UI afterward).

To override anything, edit `.env` and restart the stack. Uncommon overrides
(timezone, custom domain, reverse proxy) are documented in [`docs/SECURITY.md`](docs/SECURITY.md).

## Security

Default install is localhost-only and safe for single-user personal use.
Before exposing any service to the internet, read [`docs/SECURITY.md`](docs/SECURITY.md)
— it covers SSH tunnels, Cloudflare Tunnel, Tailscale, and reverse-proxy
setups with real config examples.

## Contributing

Issues and PRs welcome. The high-leverage places to contribute right now:

1. **More examples** in `examples/` — any real pipeline you've built.
2. **OS support** — the installer is tested on Ubuntu and Debian; macOS and
   WSL2 should work but aren't CI-verified yet.
3. **Metabase dashboard templates** as serialized JSON that users can import.

## License

MIT. See [LICENSE](LICENSE).
