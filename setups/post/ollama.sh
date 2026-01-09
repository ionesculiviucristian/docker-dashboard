#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source "./.env" && set +a

#shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

wait_for_service "ollama" "ollama list"

info_msg "Pulling ${OLLAMA_MODEL} model..."

if ! output=$(docker compose exec -T ollama ollama pull "${OLLAMA_MODEL}" 2>&1); then
  error_msg "${output}"
  exit 1
fi

exit 0
