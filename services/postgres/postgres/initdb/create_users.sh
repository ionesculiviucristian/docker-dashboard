#!/bin/bash
set -eu

PGPASSWORD="$(cat /run/secrets/POSTGRES_PASSWORD)"
export PGPASSWORD

psql -v ON_ERROR_STOP=1 --username "postgres" <<-EOSQL
  CREATE USER ${POSTGRES_SERVICES_USER} WITH CREATEDB PASSWORD '$(cat /run/secrets/POSTGRES_SERVICES_USER_PASSWORRD)';
EOSQL
