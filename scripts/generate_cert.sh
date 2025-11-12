#!/bin/bash

set -eu

if [ $# -ne 1 ]; then
  echo "Error: Domain prefix is required"
  exit 1
fi

domain_prefix="$1"
domain="${domain_prefix}.local"
certs_dir="./services/traefik/certs"

mkdir -p "${certs_dir}"

mkcert \
  -cert-file "${certs_dir}/${domain}.crt" \
  -key-file "${certs_dir}/${domain}.key" \
  "*.${domain}" "${domain}"

exit 0
