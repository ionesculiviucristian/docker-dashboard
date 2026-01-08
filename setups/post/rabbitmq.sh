#!/bin/bash
set -eu 

docker compose exec rabbitmq rabbitmq-plugins enable rabbitmq_prometheus

exit 0
