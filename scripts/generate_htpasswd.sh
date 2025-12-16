#!/bin/bash
set -eu 

hostname=$1
force=${2:-false}

if [ -z "${hostname}" ]; then
  echo "Error: Hostname is required"
  exit 1
fi

# shellcheck disable=SC1091
set -a && source "./.env" && set +a

htpasswd_file="./services/nginx-proxy/htpasswd/${hostname}"

if [[ -f "${htpasswd_file}" && "${force}" = false ]]; then
  exit 0
fi

# shellcheck disable=SC2005
echo "$(
  docker run --rm \
    --entrypoint htpasswd \
    httpd:2 \
    -Bbn "${SERVICES_USER}" "${SERVICES_USER_PASSWORD}"
)" > "${htpasswd_file}"

exit 0
