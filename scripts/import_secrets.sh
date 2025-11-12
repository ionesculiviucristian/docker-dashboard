#!/bin/bash
set -eu

email="$1"

if [ -z "${email}" ]; then
  echo "Error: E-mail is required"
  exit 1
fi

# shellcheck disable=SC1091
set -a && source ".env" && set +a

BW_SESSION=$(bw login "${email}" --method 0 --raw)
export BW_SESSION

bw get attachment "bookmarks.yaml" --itemid "Docker dashboard bookmarks" --raw | \
  tee "./services/homepage/config/bookmarks.yaml" > /dev/null

bw logout

docker restart dev-homepage-1

exit 0
