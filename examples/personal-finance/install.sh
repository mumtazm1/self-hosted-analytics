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
  existing=$("${PSQL[@]}" -At -c \
    "SELECT COALESCE(SUM(c), 0) FROM (
       SELECT count(*) AS c FROM finance.transactions
       UNION ALL SELECT count(*) FROM finance.balance_snapshots
       UNION ALL SELECT count(*) FROM finance.accounts
     ) s")
  if [[ "$existing" -gt 0 && "$FORCE" -ne 1 ]]; then
    error "finance.* already contains $existing rows. Refusing to truncate."
    error "Re-run with --force if you really want to wipe and reseed."
    exit 1
  fi
  echo "==> Loading seed data (re-runnable; truncates finance.*)"
  "${PSQL[@]}" < "$EXAMPLE_DIR/seed.sql"
fi

echo ""
success "Finance schema is loaded."
echo "Next: open Metabase, connect to the '${POSTGRES_DB}' database, and"
echo "follow examples/personal-finance/README.md to build the dashboard"
echo "from dashboard-queries.sql."
