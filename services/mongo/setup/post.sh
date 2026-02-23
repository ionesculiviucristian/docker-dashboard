#!/bin/bash
set -eu 

# shellcheck source=../../../.env
set -a && source "./.env" && set +a

# shellcheck source=../../../scripts/helpers.sh
source "./scripts/helpers.sh"

wait_for_service "mongo" "mongosh --eval \"db.adminCommand('ping')\""

if exec_output=$(docker compose exec mongo mongosh \
  -u "${SERVICES_USER}" \
  -p "${SERVICES_USER_PASSWORD}" \
  --quiet --eval "rs.conf()._id" 2>&1 \
); then
  if [ "${exec_output}" == "rs0" ]; then
    info_msg "MongoDB replica set is already initiated"
    exit 0
  fi
fi

if exec_output=$(docker compose exec mongo mongosh \
  -u "${SERVICES_USER}" \
  -p "${SERVICES_USER_PASSWORD}" \
  --eval 'rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "mongo:27017" }] })' 2>&1 \
); then
  info_msg "MongoDB replica set initiated"
else
  error_msg "${exec_output}"
fi

exit 0
