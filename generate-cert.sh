#!/bin/bash
set -eu 

if [ -z "$1" ]; then
  echo "Error: No hostname provided. Usage: $0 <hostname>"
  exit 1
fi

HOSTNAME=$1

mkcert -cert-file ./.certs/${HOSTNAME}.crt -key-file ./.certs/${HOSTNAME}.key ${HOSTNAME} *.${HOSTNAME}

if ! grep -q "${HOSTNAME}" /etc/hosts; then
  echo "127.0.0.1 ${HOSTNAME}" | sudo tee -a /etc/hosts
fi
