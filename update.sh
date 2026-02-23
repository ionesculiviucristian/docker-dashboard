#!/bin/bash
set -eu

source "./scripts/helpers.sh"

info_msg "Start updating..."

info_msg "Updating .env file..." && ./scripts/update_dot_env.sh

info_msg "Starting services..."

if ! output=$(docker compose up -d 2>&1); then
  error_msg "${output}"
  exit 1
fi

info_msg "Removing unused docker data..."

if ! output=$(docker system prune -f 2>&1); then
  error_msg "${output}"
  exit 1
fi

success_msg "Finished updating"

exit 0
