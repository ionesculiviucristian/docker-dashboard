#!/bin/bash
set -eu

if [ $# -ne 1 ]; then
  echo "Error: Network is required"
  exit 1
fi

network="$1"

if ! docker network inspect "${network}" >/dev/null 2>&1; then
    docker network create "${network}" >/dev/null
    echo -e "\u2705 Created network ${network}"
else
    echo -e "\u2139 Network ${network} already exists"
fi

exit 0
 