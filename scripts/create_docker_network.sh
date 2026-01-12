#!/bin/bash
set -eu

# shellcheck source="./helpers.sh"
source "./scripts/helpers.sh"

if [ $# -ne 1 ]; then
  error_msg "Network name is required"
  exit 1
fi

network_name="$1"

if ! docker network inspect "${network_name}" >/dev/null 2>&1; then
    network_id=$(docker network create "${network_name}")
    success_msg "Created network ${network_name} with ID ${network_id}"
else
    info_msg "Network ${network_name} already exists"
fi

exit 0
