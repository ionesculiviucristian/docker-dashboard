#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source ".env" && set +a

# shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

wait_for_service "postgres" "pg_isready -U '${POSTGRES_USER}'"

./scripts/create_postgres_db.sh \
  "${AUTHENTIK_POSTGRES_DB}" \
  "${AUTHENTIK_POSTGRES_USER}" \
  "${AUTHENTIK_POSTGRES_USER_PASSWORD}"

exit 0
