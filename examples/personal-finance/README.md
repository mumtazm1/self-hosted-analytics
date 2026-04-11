# Example: Personal Finance

End-to-end pipeline that pulls transactions from an external source, lands
them in Postgres, and surfaces them in a pre-built Metabase dashboard.

## Status

**Scaffold only.** The schema is ready. The n8n workflow export and Metabase
dashboard export need to be dropped in from a real working pipeline. See
"What's missing" below.

## What this example will do (when complete)

1. An n8n workflow runs on a schedule and pulls transaction data from a
   source (e.g. SimpleFin, Plaid, or a bank's CSV export).
2. Rows land in `analytics.finance_transactions` in Postgres.
3. A pre-built Metabase dashboard queries that table and shows:
   - Monthly spending by category
   - Income vs expenses trend
   - Top merchants
   - Account balances over time

## Files in this directory

| File                       | Purpose                                            |
|----------------------------|----------------------------------------------------|
| `schema.sql`               | Creates the `finance_transactions` table          |
| `install.sh`               | Loads schema + imports n8n/Metabase JSON          |
| `n8n-workflow.json`        | *(missing)* Sanitized n8n workflow export        |
| `metabase-dashboard.json`  | *(missing)* Serialized Metabase dashboard        |
| `screenshots/`             | *(missing)* Dashboard screenshots for the README |

## Install

Once the missing files are in place:

```bash
cd examples/personal-finance
./install.sh
```

This assumes the main stack is already running (`../../install.sh` from
repo root).

## What's missing (for the maintainer)

To finish this example:

1. **Record a Loom** walking through your actual working SimpleFin → Postgres
   → Metabase pipeline.
2. **Export the n8n workflow** via the UI (Download) and save it as
   `n8n-workflow.json`. Replace any real credentials with placeholder strings
   like `<YOUR_SIMPLEFIN_TOKEN>`. Document which credentials the user needs
   to create in the n8n UI after import.
3. **Serialize the Metabase dashboard** via the Metabase serialization API
   or the `export` command, save as `metabase-dashboard.json`. Same
   placeholder treatment for any hardcoded table references.
4. **Drop 4–6 screenshots** into `screenshots/` (hero image + detail views).
5. **Finish `install.sh`** — currently it only loads the schema. Extend it to
   POST the n8n workflow via n8n's public API and import the Metabase
   dashboard via Metabase's serialization endpoint.

Once those are in place, delete this "What's missing" section and update the
main [README](../../README.md) to link this as a working example.
