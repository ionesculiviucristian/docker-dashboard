#!/bin/bash
set -eu

# shellcheck source="./helpers.sh"
source "./scripts/helpers.sh"

if [ $# -lt 3 ]; then
  error_msg "Usage: create_gotify_client.sh <type> <name> <env_var>"
  error_msg "  type: application or client"
  exit 1
fi

type="$1"
name="$2"
env_var="$3"

current_value=$(grep "^${env_var}=" "./.env" | cut -d'"' -f2)

if [ -n "${current_value}" ]; then
  warning_msg "${env_var} is already set"
  exit 0
fi

wait_for_service "gotify" \
  "curl -sf http://127.0.0.1:${GOTIFY_HOSTNAME_PORT}/health"

info_msg "Creating Gotify ${type} '${name}'..."

response=$(
  docker compose exec -T gotify curl -sf \
    -u "${GOTIFY_DEFAULTUSER_NAME}:${GOTIFY_DEFAULTUSER_PASS}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"${name}\"}" \
    "http://gotify:${GOTIFY_HOSTNAME_PORT}/${type}"
)

token=$(echo "${response}" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "${token}" ]; then
  error_msg "Failed to extract Gotify ${type} token from response"
  exit 1
fi

sed -i "s|^${env_var}=.*|${env_var}=\"${token}\"|" "./.env"

success_msg "Gotify ${type} '${name}' created"

exit 0
