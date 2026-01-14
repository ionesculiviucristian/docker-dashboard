#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source "./.env" && set +a

# shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

info_msg "Configuring n8n owner account..."

wait_for_service "n8n" "wget --spider -q http://127.0.0.1:5678/healthz"

payload=$(cat <<EOF
{
  "email": "${SERVICES_USER_EMAIL}",
  "password": "${SERVICES_USER_PASSWORD}",
  "firstName": "${SERVICES_USER}",
  "lastName": "${SERVICES_USER}"
}
EOF
)

response=$(curl -k -s -X POST "https://${N8N_HOSTNAME}/rest/owner/setup" \
  -H "Content-Type: application/json" \
  -d "${payload}" \
  -w "\n%{http_code}"
)

http_code=$(echo "${response}" | tail -1)
body=$(echo "${response}" | head -n -1)

if [ "${http_code}" = "200" ] || [ "${http_code}" = "201" ]; then
  info_msg "n8n owner account created successfully"
elif echo "${body}" | grep -q "owner.*already"; then
  info_msg "n8n owner already configured"
else
  error_msg "Automatic setup failed (HTTP ${http_code})"
fi

exit 0
