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
FORCE=${2:-false}

HTPASSWD_FILE="./services/nginx-proxy/htpasswd/${HOSTNAME}"

if [[ -f "${HTPASSWD_FILE}" && "${FORCE}" = false ]]; then
  exit 0
fi

# shellcheck disable=SC2005
echo "$(docker run --rm --entrypoint htpasswd httpd:2 -Bbn "${SERVICES_USER}" "${SERVICES_USER_PASSWORRD}")" > "${HTPASSWD_FILE}";

exit 0
