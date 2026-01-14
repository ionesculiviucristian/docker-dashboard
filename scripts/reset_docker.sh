#!/bin/bash
# shellcheck disable=SC2046
set -eu

# shellcheck source="./helpers.sh"
source "./scripts/helpers.sh"

info_msg "Resetting docker dashboard (containers, volumes, networks)..."

docker compose stop >/dev/null 2>&1 || true
docker compose rm -f >/dev/null 2>&1 || true
docker compose down -v --remove-orphans >/dev/null 2>&1 || true

success_msg "Docker dashboard resources reset successfully"
