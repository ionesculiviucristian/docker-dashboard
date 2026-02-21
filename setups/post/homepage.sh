#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source "./.env" && set +a

# shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

# ./scripts/create_gotify_client.sh \
#   "client" \
#   "Homepage" \
#   "HOMEPAGE_GOTIFY_TOKEN" |
#   indent_msg

if [ -z "$(grep "^HOMEPAGE_MEALIE_TOKEN=" "./.env" | cut -d'"' -f2)" ]; then
  wait_for_service "mealie" "python -m mealie.scripts.healthcheck" 60

  info_msg "Creating Mealie API token for Homepage..."

  base_url="https://${MEALIE_HOSTNAME}"

  auth_response=$(
    curl -sk \
      -X POST \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "username=${SERVICES_USER_EMAIL}&password=${SERVICES_USER_PASSWORD}" \
      "${base_url}/api/auth/token"
  )

  access_token=$(echo "${auth_response}" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

  if [ -z "${access_token}" ]; then
    error_msg "Failed to authenticate with Mealie"
  else
    token_response=$(
      curl -sk \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${access_token}" \
        -d '{"name":"Homepage"}' \
        "${base_url}/api/users/api-tokens"
    )

    mealie_token=$(echo "${token_response}" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

    if [ -z "${mealie_token}" ]; then
      error_msg "Failed to create Mealie API token"
    else
      sed -i "s|^HOMEPAGE_MEALIE_TOKEN=.*|HOMEPAGE_MEALIE_TOKEN=\"${mealie_token}\"|" "./.env"
      success_msg "Mealie API token created for Homepage"
    fi
  fi
else
  warning_msg "HOMEPAGE_MEALIE_TOKEN is already set"
fi

docker compose up -d --force-recreate homepage

exit 0
