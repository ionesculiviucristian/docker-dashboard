#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source ".env" && set +a

echo "Waiting for RabbitMQ to be ready..."
until docker compose exec rabbitmq rabbitmq-diagnostics ping >/dev/null 2>&1; do
  echo -n "."
  sleep 2
done

docker compose exec rabbitmq rabbitmq-plugins enable rabbitmq_prometheus

exit 0
