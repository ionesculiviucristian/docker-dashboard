#!/bin/bash
# shellcheck disable=SC2046
set -eu

# shellcheck source="./helpers.sh"
source "./scripts/helpers.sh"

info_msg "Resetting Docker (containers, volumes, networks)..."

docker stop $(docker ps -aq) >/dev/null 2>&1 || true
docker rm $(docker ps -aq) >/dev/null 2>&1 || true
docker volume rm $(docker volume ls -q) >/dev/null 2>&1 || true
docker network rm $(docker network ls --filter type=custom -q) >/dev/null 2>&1 || true

success_msg "Docker reset successfully"
