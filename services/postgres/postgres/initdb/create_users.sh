#!/bin/bash
set -eu

PGPASSWORD="$(cat /run/secrets/POSTGRES_PASSWORD)"
export PGPASSWORD

psql -v ON_ERROR_STOP=1 --username "postgres" <<-EOSQL
  CREATE USER ${POSTGRES_DEV_USER} WITH CREATEDB PASSWORD '$(cat /run/secrets/POSTGRES_DEV_PASSWORD)';
EOSQL
