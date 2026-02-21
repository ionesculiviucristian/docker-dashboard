#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source "./.env" && set +a

# shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

if [ -n "${WHATSUPDOCKER_GOTIFY_TOKEN:-}" ]; then
  info_msg "Gotify token already configured"
  exit 0
fi

wait_for_service "gotify" "curl -sf http://127.0.0.1:${GOTIFY_HOSTNAME_PORT}/health"

info_msg "Creating Gotify application for What's up Docker..."

response=$(
  docker compose exec -T gotify curl -sf \
    -u "${GOTIFY_DEFAULTUSER_NAME}:${GOTIFY_DEFAULTUSER_PASS}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"name":"WUD","description":"Container update notifications","defaultPriority":5}' \
    "http://gotify:${GOTIFY_HOSTNAME_PORT}/application"
)

token=$(echo "${response}" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "${token}" ]; then
  error_msg "Failed to extract Gotify token from response"
  exit 1
fi

sed -i \
  "s|^WHATSUPDOCKER_GOTIFY_TOKEN=.*|WHATSUPDOCKER_GOTIFY_TOKEN=\"${token}\"|" \
  "./.env"

info_msg "Gotify application created, restarting What's up Docker..."

docker compose up -d whatsupdocker

info_msg "What's up Docker integrated with Gotify"

exit 0
