#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source "./.env" && set +a

# shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

./scripts/create_gotify_client.sh \
  "application" \
  "WUD" \
  "WHATSUPDOCKER_GOTIFY_TOKEN" |
  indent_msg

docker compose up -d --force-recreate whatsupdocker

exit 0
