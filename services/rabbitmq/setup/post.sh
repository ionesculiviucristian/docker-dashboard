#!/bin/bash
set -eu

# shellcheck source=../../../.env
set -a && source ".env" && set +a

# shellcheck source=../../../scripts/helpers.sh
source "./scripts/helpers.sh"

wait_for_service "rabbitmq" "rabbitmq-diagnostics ping"

info_msg "Enabling RabbitMQ plugins..."

if ! exec_output=$(docker compose exec rabbitmq \
  rabbitmq-plugins enable rabbitmq_prometheus \
); then
  error_msg "${exec_output}"
else
  if echo "${exec_output}" | grep "Error"; then
    error_msg "${exec_output}"
  fi
fi

exit 0
