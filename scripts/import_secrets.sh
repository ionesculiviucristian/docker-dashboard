#!/bin/bash
set -eu

if [ $# -ne 1 ]; then
  echo "Error: E-mail is required"
  exit 1
fi

email="$1"

# shellcheck source=../.env
set -a && source ".env" && set +a

BW_SESSION=$(bw login "${email}" --method 0 --raw)
export BW_SESSION

bw get attachment "bookmarks.yaml" --itemid "Docker dashboard bookmarks" --raw | \
  tee "./services/homepage/config/bookmarks.yaml" > /dev/null

bw logout

docker compose restart homepage

exit 0
