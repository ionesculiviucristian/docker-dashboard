#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source ".env" && set +a

#shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

wait_for_service "rabbitmq" "rabbitmq-diagnostics ping"

if ! output=$(docker compose exec rabbitmq rabbitmq-plugins enable rabbitmq_prometheus 2>&1); then
  error_msg "${output}"
  exit 1
fi

exit 0
