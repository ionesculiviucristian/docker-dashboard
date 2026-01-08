#!/bin/bash
set -eu

if [ $# -ne 3 ]; then
  echo "Error: Database, username and password are required"
  exit 1
fi

database="$1"
username="$2"
password="$3"

# shellcheck source=../.env
set -a && source ".env" && set +a

docker compose exec -T postgres psql -U "${POSTGRES_USER}" <<-EOSQL
CREATE DATABASE ${database};
CREATE USER ${username} WITH PASSWORD '${password}';
GRANT ALL PRIVILEGES ON DATABASE ${database} TO ${username};
EOSQL

echo -e "\u2705 Created database '${database}' and user '${username}'"

exit 0
