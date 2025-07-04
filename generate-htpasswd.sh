#!/bin/bash
set -eu 

# TODO: add force flag

if [ -z "$1" ]; then
  echo "Error: No hostname provided. Usage: $0 <hostname>"
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

HOSTNAME=$1

# shellcheck disable=SC2005
echo "$(docker run --rm --entrypoint htpasswd httpd:2 -Bbn "${DEV_USER}" "${DEV_PASSWORD}")" > "./services/nginx-proxy/htpasswd/${HOSTNAME}";
