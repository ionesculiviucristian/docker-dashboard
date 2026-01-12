#!/bin/bash
set -eu 

# shellcheck source=../../.env
set -a && source "./.env" && set +a

# shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

wait_for_service "mongo" "mongosh --eval \"db.adminCommand('ping')\""

is_initiated=$(docker compose exec -T mongo mongosh \
  -u "${SERVICES_USER}" \
  -p "${SERVICES_USER_PASSWORD}" \
  --quiet --eval "try { rs.conf()._id } catch(e) { null }" 2>/dev/null || echo "null"
)

if [ "${is_initiated}" == "rs0" ]; then
  debug_msg "MongoDB replica set is already initiated"
else
  docker compose exec mongo mongosh \
    -u "${SERVICES_USER}" \
    -p "${SERVICES_USER_PASSWORD}" \
    --eval 'rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "mongo:27017" }] })' >/dev/null

  debug_msg "MongoDB replica set initiated"
fi

exit 0
