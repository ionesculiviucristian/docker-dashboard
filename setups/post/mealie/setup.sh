#!/bin/bash
set -eu

# shellcheck source=../../../.env
set -a && source "./.env" && set +a

# shellcheck source="../../../scripts/helpers.sh"
source "./scripts/helpers.sh"

default_email="changeme@example.com"
script_path="/tmp/configure_admin.py"

# shellcheck disable=SC2027
trap "docker compose exec mealie rm -f "${script_path}" >/dev/null 2>&1" EXIT

info_msg "Configuring Mealie admin account..."

wait_for_service "mealie" "python -m mealie.scripts.healthcheck" 60

docker compose cp "./setups/post/mealie/configure_admin.py" mealie:${script_path} >/dev/null 2>&1

if result=$(docker compose exec mealie python3 ${script_path} \
  "${default_email}" \
  "${SERVICES_USER}" \
  "${SERVICES_USER_EMAIL}" \
  "${SERVICES_USER_PASSWORD}" 2>&1 \
); then
  if [ "${result}" = "success" ]; then
    success_msg "Mealie admin account updated successfully"
  elif [ "${result}" = "not_found" ]; then
    info_msg "Mealie already configured (default user not found)"
  fi
  exit 0
else
  error_msg "Failed to configure Mealie admin: ${result}"
  exit 1
fi
