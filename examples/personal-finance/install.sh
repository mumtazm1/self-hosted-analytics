#!/bin/bash
# Load the personal-finance example into a running stack.
# Assumes the main stack has been started via the repo root install.sh.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--with-sample-data] [--help]

  --with-sample-data   Also load 50 synthetic transactions and balance
                       snapshots from seed.sql so the dashboard renders
                       immediately. Safe to re-run; truncates first.
  --help               Show this message.
EOF
}

WITH_SAMPLE_DATA=0
case "${1:-}" in
  --with-sample-data) WITH_SAMPLE_DATA=1 ;;
  --help|-h)          usage; exit 0 ;;
  "")                 ;;
  *)                  usage >&2; exit 2 ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "No .env found. Run ./install.sh from the repo root first." >&2
  exit 1
fi
# shellcheck disable=SC1091
set -a; source .env; set +a

# POSTGRES_HOST doubles as the postgres container name. docker-compose.yml
# sets container_name: ${POSTGRES_HOST:-postgres}. Keep these in lockstep
# if you rename either.
PG_CONTAINER="${POSTGRES_HOST:-postgres}"
PG_USER="${POSTGRES_USER}"
PG_DB="${POSTGRES_DB:-analytics}"

echo "==> Loading schema into ${PG_DB} database"
docker exec -i "$PG_CONTAINER" psql -U "$PG_USER" -d "$PG_DB" < "$SCRIPT_DIR/schema.sql"

if [[ "$WITH_SAMPLE_DATA" -eq 1 ]]; then
  echo "==> Loading seed data (50 sample transactions across 6 months)"
  docker exec -i "$PG_CONTAINER" psql -U "$PG_USER" -d "$PG_DB" < "$SCRIPT_DIR/seed.sql"
fi

if [[ -f "$SCRIPT_DIR/n8n-workflow.json" ]]; then
  echo "==> n8n workflow JSON found at $SCRIPT_DIR/n8n-workflow.json"
  echo "    Import manually: n8n UI (http://localhost:5678) -> Workflows -> Import from File"
else
  echo "    n8n-workflow.json not present. See README for the workflow walkthrough."
fi

echo ""
echo "Done. The finance schema is loaded."
echo "Next: open Metabase (http://localhost:3000), connect to the 'analytics'"
echo "database, and follow examples/personal-finance/README.md to build the"
echo "dashboard from dashboard-queries.sql."
