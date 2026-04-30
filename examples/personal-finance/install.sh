#!/bin/bash
# Load the personal-finance example into a running stack.
# Assumes the main stack has been started via the repo root install.sh.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--with-sample-data] [--force] [--help]

  --with-sample-data   Also load synthetic transactions from seed.sql so
                       the dashboard renders without a live pipeline.
                       Refuses if finance.transactions already has rows
                       (won't clobber real data without --force).
  --force              Required with --with-sample-data when the table is
                       not empty. Truncates finance.* and reloads.
  --help               Show this message.
EOF
}

WITH_SAMPLE_DATA=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --with-sample-data) WITH_SAMPLE_DATA=1 ;;
    --force)            FORCE=1 ;;
    -h|--help)          usage; exit 0 ;;
    *)                  usage >&2; exit 2 ;;
  esac
done

if [[ "$FORCE" -eq 1 && "$WITH_SAMPLE_DATA" -eq 0 ]]; then
  echo "--force only applies with --with-sample-data." >&2
  exit 2
fi

# Resolve our directory before sourcing common.sh, which reassigns SCRIPT_DIR.
EXAMPLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$EXAMPLE_DIR/../../scripts/common.sh"

if [[ ! -f "$PROJECT_ROOT/.env" ]]; then
  error ".env not found at $PROJECT_ROOT/.env. Run ./install.sh from the repo root first."
  exit 1
fi

PSQL=(docker exec -i "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB")

echo "==> Loading schema into ${POSTGRES_DB} database"
"${PSQL[@]}" < "$EXAMPLE_DIR/schema.sql"

if [[ "$WITH_SAMPLE_DATA" -eq 1 ]]; then
  # Only the transactions table matters here. accounts / snapshots being
  # non-empty alongside an empty transactions table is a weird state, but
  # not the "real data is here" signal we're trying to protect.
  existing=$("${PSQL[@]}" -At -c "SELECT count(*) FROM finance.transactions")
  if [[ "$existing" -gt 0 && "$FORCE" -ne 1 ]]; then
    error "finance.transactions already contains $existing rows. Refusing to truncate."
    error "Re-run with --force if you really want to wipe and reseed."
    exit 1
  fi
  echo "==> Loading seed data (re-runnable; truncates finance.*)"
  "${PSQL[@]}" < "$EXAMPLE_DIR/seed.sql"
fi

echo ""
if [[ "$WITH_SAMPLE_DATA" -eq 1 ]]; then
  success "Finance schema and 6 months of synthetic data loaded into ${POSTGRES_DB}."
  echo "Next: open Metabase, connect to the '${POSTGRES_DB}' database, and follow"
  echo "examples/personal-finance/README.md to build the dashboard from"
  echo "dashboard-queries.sql. Each query already returns rows."
else
  success "Finance schema loaded into ${POSTGRES_DB}."
  echo "Next: wire something into finance.transactions (n8n CSV import, a Python"
  echo "script, \\copy from a file). Or re-run with --with-sample-data to load"
  echo "synthetic data and try the dashboard."
fi
