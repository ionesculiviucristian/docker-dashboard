#!/bin/bash
set -eu

if [ $# -ne 1 ]; then
  echo "Error: Domain name is required"
  exit 1
fi

certs_dir="./services/traefik/certs"
domain_name="$1"

mkdir -p "${certs_dir}"

mkcert \
  -cert-file "${certs_dir}/${domain_name}.crt" \
  -key-file "${certs_dir}/${domain_name}.key" \
  "*.${domain_name}" "${domain_name}"

exit 0
