#!/bin/bash
set -eu 

# shellcheck source=../../.env
set -a && source "./.env" && set +a

echo "Waiting for MongoDB to be ready..."
until docker compose exec mongo mongosh --eval "db.adminCommand('ping')" >/dev/null 2>&1; do
  echo -n "."
  sleep 2
done

docker compose exec mongo mongosh \
  -u "${SERVICES_USER}" \
  -p "${SERVICES_USER_PASSWORD}" \
  --eval 'rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "mongo:27017" }] })'

exit 0
