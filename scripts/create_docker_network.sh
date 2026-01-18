#!/bin/bash
set -eu

# shellcheck source="./helpers.sh"
source "./scripts/helpers.sh"

if [ $# -ne 1 ]; then
  error_msg "Docker network name is required"
  exit 1
fi

name="$1"

info_msg "Creating ${name} docker network..." true

if inspect_output=$(docker network inspect "${name}" 2>&1); then
  status_skip
  exit 0
else
  if ! echo "${inspect_output}" | grep -q "not found"; then
    status_fail "${inspect_output}"
    exit 1
  fi
fi

if create_output=$(docker network create "${name}" 2>&1); then
  status_ok
  exit 0
else
  status_fail "${create_output}"
  exit 1
fi
