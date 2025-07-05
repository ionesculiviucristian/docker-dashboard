#!/bin/bash
set -eu 

if [ -z "$1" ]; then
  echo "Error: No hostname provided."
  echo "Usage: $0 <hostname> [--force]"
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

HOSTNAME=$1
FORCE=false

HTPASSWD_FILE="./services/nginx-proxy/htpasswd/${HOSTNAME}"

if [ "$2" == "--force" ]; then
  FORCE=true
fi

if [[ -f "${HTPASSWD_FILE}" && "${FORCE}" = false ]]; then
  exit 0
fi

# shellcheck disable=SC2005
echo "$(docker run --rm --entrypoint htpasswd httpd:2 -Bbn "${DEV_USER}" "${DEV_PASSWORD}")" > "${HTPASSWD_FILE}";

exit 0
