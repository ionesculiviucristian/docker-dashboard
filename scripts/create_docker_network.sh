#!/bin/bash
set -eu

# shellcheck source="./helpers.sh"
source "./scripts/helpers.sh"

if [ $# -ne 1 ]; then
  error_msg "Network name is required"
  exit 1
fi

network_name="$1"

if inspect_output=$(docker network inspect "${network_name}" 2>&1); then
  info_msg "Network ${network_name} already exists"
  exit 0
else
  if ! echo "${inspect_output}" | grep -q "not found"; then
    error_msg "${inspect_output}"
    exit 1
  fi
fi

if create_output=$(docker network create "${network_name}" 2>&1); then
  success_msg "Created network ${network_name} (${create_output})"
  exit 0
else
  error_msg "${create_output}"
  exit 1
fi
