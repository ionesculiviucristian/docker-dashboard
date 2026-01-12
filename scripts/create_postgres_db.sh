#!/bin/bash
set -eu

# shellcheck source=../.env
set -a && source ".env" && set +a

# shellcheck source="../scripts/helpers.sh"
source "./scripts/helpers.sh"

if [ $# -ne 3 ]; then
  error "Database, username and password are required"
  exit 1
fi

database="$1"
username="$2"
password="$3"

pg_query() {
  docker compose exec -T postgres psql -U "${POSTGRES_USER}" -tAn -c "$1"
}

user_exists=$(pg_query "SELECT 1 FROM pg_roles WHERE rolname='${username}'")

if [ "${user_exists}" == "1" ]; then
  info_msg "User ${username} already exists"
else
  pg_query "CREATE USER ${username} WITH PASSWORD '${password}'" >/dev/null
  success_msg "Created $username user"
fi

db_exists=$(pg_query "SELECT 1 FROM pg_database WHERE datname='${database}'")

if [ "${db_exists}" == "1" ]; then
  info_msg "Database ${database} already exists"
else
  pg_query "CREATE DATABASE ${database}" >/dev/null
  success_msg "Created ${database} database"
fi

pg_query "GRANT ALL PRIVILEGES ON DATABASE ${database} TO ${username}" >/dev/null
debug_msg "Granted all privileges for '$username' on '${database}'"

exit 0
