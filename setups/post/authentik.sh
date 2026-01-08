#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source ".env" && set +a

echo "Waiting for PostgreSQL to be ready..."
until docker compose exec postgres pg_isready -U "${POSTGRES_USER}" >/dev/null 2>&1; do
  echo -n "."
  sleep 2
done

./scripts/create_postgres_db.sh \
  "${AUTHENTIK_POSTGRES_DB}" \
  "${AUTHENTIK_POSTGRES_USER}" \
  "${AUTHENTIK_POSTGRES_USER_PASSWORD}"

exit 0
