#!/bin/bash
# Load the personal-finance example into a running stack.
# Assumes the main stack has been started via the repo root install.sh.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "No .env found. Run ./install.sh from the repo root first." >&2
  exit 1
fi
# shellcheck disable=SC1091
set -a; source .env; set +a

echo "==> Loading schema into analytics database"
# POSTGRES_HOST doubles as the postgres container name. docker-compose.yml
# sets container_name: ${POSTGRES_HOST:-postgres}. Keep these in lockstep
# if you rename either.
docker exec -i "${POSTGRES_HOST:-postgres}" \
  psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB:-analytics}" \
  < "$SCRIPT_DIR/schema.sql"

if [[ -f "$SCRIPT_DIR/n8n-workflow.json" ]]; then
  echo "==> Importing n8n workflow"
  echo "    TODO: hit n8n public API at http://localhost:5678/api/v1/workflows"
  echo "    Currently a manual step: open n8n UI, Import from File, select:"
  echo "    $SCRIPT_DIR/n8n-workflow.json"
else
  echo "!!! n8n-workflow.json not present yet. Skipping n8n import."
fi

if [[ -f "$SCRIPT_DIR/metabase-dashboard.json" ]]; then
  echo "==> Importing Metabase dashboard"
  echo "    TODO: hit Metabase serialization endpoint"
  echo "    Currently a manual step: open Metabase, Settings > Admin > Serialization"
else
  echo "!!! metabase-dashboard.json not present yet. Skipping Metabase import."
fi

echo ""
echo "Done. The finance schema is loaded."
echo "Open Metabase at http://localhost:3000 and point a new dashboard at"
echo "the 'finance' schema in the 'analytics' database."
