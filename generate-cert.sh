#!/bin/bash
set -eu 

if [ -z "$1" ]; then
  echo "Error: No hostname provided."
  echo "Usage: $0 <hostname> [--force]"
  exit 1
fi

HOSTNAME=$1
FORCE=${2:-false}

CERT_FILE="./.certs/${HOSTNAME}.crt"
KEY_FILE="./.certs/${HOSTNAME}.key"

HOSTS_FILE="/etc/hosts"

if [[ -f "${CERT_FILE}" && -f "${KEY_FILE}" && "${FORCE}" = false ]]; then
  exit 0
fi

mkcert -cert-file "${CERT_FILE}" -key-file "${KEY_FILE}" "${HOSTNAME}" "*.${HOSTNAME}"

if ! grep -q "${HOSTNAME}" "${HOSTS_FILE}"; then
  echo "127.0.0.1 ${HOSTNAME}" | sudo tee -a "${HOSTS_FILE}"
fi

exit 0
