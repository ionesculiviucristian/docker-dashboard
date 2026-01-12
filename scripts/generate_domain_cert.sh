#!/bin/bash
set -eu

# shellcheck source="./helpers.sh"
source "./scripts/helpers.sh"

if [ $# -ne 1 ]; then
  error_msg "Domain name is required"
  exit 1
fi

certs_dir="./services/traefik/certs"
domain_name="$1"

mkdir -p "${certs_dir}"

mkcert \
  -cert-file "${certs_dir}/${domain_name}.crt" \
  -key-file "${certs_dir}/${domain_name}.key" \
  "*.${domain_name}" "${domain_name}" >/dev/null 2>&1

info_msg "Created ${domain_name} domain certificate"

exit 0
