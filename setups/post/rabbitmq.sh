#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source ".env" && set +a

# shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

wait_for_service "rabbitmq" "rabbitmq-diagnostics ping"

info_msg "Enabling RabbitMQ plugins..."

docker compose exec rabbitmq rabbitmq-plugins enable rabbitmq_prometheus >/dev/null

exit 0
