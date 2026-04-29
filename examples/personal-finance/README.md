# Example: Personal Finance

A `finance` schema in the `analytics` database, plus seed data and SQL
queries for a Metabase dashboard. Build the dashboard once and you have
a place to point real ingestion at — n8n from a CSV, a Python script
from SimpleFin/Plaid, whatever.

## What's here

| File                   | Purpose                                                             |
|------------------------|---------------------------------------------------------------------|
| `schema.sql`           | Creates the `finance` schema and three tables                       |
| `seed.sql`             | Synthetic transactions (6 months, 3 accounts) and derived snapshots |
| `dashboard-queries.sql`| Four Native SQL queries that power the Metabase dashboard           |
| `install.sh`           | Loads the schema (and optionally seed) into a running stack         |

## Schema

`schema.sql` creates:

- `finance.accounts` — one row per bank/brokerage/credit account
- `finance.transactions` — individual transactions (amount negative for
  spending, positive for income)
- `finance.balance_snapshots` — point-in-time balances per account
- `finance.v_monthly_spending` — view aggregating spending by month and
  category

## Install

The main stack must be running first (`./install.sh` from the repo root).

```bash
# Schema only:
./examples/personal-finance/install.sh

# Schema + 6 months of synthetic data so the dashboard renders immediately:
./examples/personal-finance/install.sh --with-sample-data
```

`--with-sample-data` refuses to run if `finance.*` already contains rows.
Pass `--force` to truncate and reseed.

## Build the dashboard

Metabase OSS doesn't have a clean dashboard import path (serialization
exports YAML directories and the import API is gated to Pro), so the
dashboard is built once by hand from `dashboard-queries.sql`. Five
minutes of clicking, then it's done.

1. Open Metabase at the URL printed by `./install.sh` (default
   `http://localhost:3000`). Connect to the `analytics` database if you
   haven't already.
2. For each of the four queries in `dashboard-queries.sql`:
   - **+ New** → **SQL query** → pick the `analytics` database
   - Paste the query
   - **Visualize** → pick the chart type noted in the comment above each
     query (bar / row / table / line)
   - Save into a new "Finance Overview" collection
3. **+ New** → **Dashboard** → "Finance Overview" → add the four saved
   questions and arrange.

A reference screenshot will land in a follow-up PR.

## Wiring real data in

The schema is what the dashboard reads from. Anything that writes rows
to `finance.transactions` will show up.

- **n8n:** webhook trigger → CSV/JSON parse → Postgres insert. A
  prebuilt workflow JSON will land in a follow-up PR.
- **Python / Prefect:** a small script that pulls from SimpleFin, Plaid,
  or a bank's CSV export and inserts via psycopg or SQLAlchemy.
- **Direct SQL:** for one-off imports, just `\copy` from a CSV.

## Versions

Built against PostgreSQL 16, n8n 2.15.1, and Metabase v0.59.6 — the
versions pinned in this stack. Dashboard query #2 (top categories) is
anchored to `MAX(posted_at)` rather than `now()`, so it works against
fixed seed data and a live pipeline alike.
