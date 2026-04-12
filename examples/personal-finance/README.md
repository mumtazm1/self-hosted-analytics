# Example: Personal Finance

Schema and installer stub for tracking personal transactions. The
pipeline (n8n workflow) and dashboard (Metabase export) are coming.
for now this sets up the database tables so you can wire your own
data source.

## What's here

| File          | Purpose                                          |
|---------------|--------------------------------------------------|
| `schema.sql`  | Creates the `finance` schema with three tables   |
| `install.sh`  | Loads the schema into a running stack             |

## Schema

`schema.sql` creates a `finance` schema in the `analytics` database:

- `finance.accounts` - bank/brokerage accounts
- `finance.transactions` - individual transactions with category, merchant, amount
- `finance.balance_snapshots` - point-in-time balances per account
- `finance.v_monthly_spending` - view that aggregates spending by month and category

## Install

Requires the main stack to be running first (`./install.sh` from repo root).

```bash
cd examples/personal-finance
./install.sh
```

## Next steps

Once the schema is loaded, connect your own data source:

- **SimpleFin / Plaid:** set up an n8n workflow that pulls transactions
  on a schedule and inserts into `finance.transactions`
- **CSV import:** write a quick Python script or use n8n's file-read node
- **Metabase:** point a new dashboard at the `finance` schema and build
  the charts you care about
