#!/bin/bash
set -eu

# shellcheck source=../../../.env
set -a && source "./.env" && set +a

# shellcheck source=../../../scripts/helpers.sh
source "./scripts/helpers.sh"

wait_for_service "ollama" "ollama list"

info_msg "Pulling ${OLLAMA_MODEL} model..."

if ! exec_output=$(docker compose exec ollama \
  ollama pull "${OLLAMA_MODEL}" 2>&1 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
); then
  error_msg "${exec_output}"
else
  if echo "${exec_output}" | grep "Error"; then
    error_msg "${exec_output}"
  fi
fi

exit 0
