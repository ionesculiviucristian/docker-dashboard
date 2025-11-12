#!/bin/bash
set -eu

certs_dir="./services/traefik/certs"
dynamic_config_file="./services/traefik/config/tls.yml"

echo "tls:" > "${dynamic_config_file}"
echo "  certificates:" >> "${dynamic_config_file}"

find "${certs_dir}" -maxdepth 1 -type f -name "*.crt" | while read -r cert_file_path; do
  cert_file=$(basename "${cert_file_path}")
  cat << EOF >> "${dynamic_config_file}"
    - certFile: "/certs/${cert_file}"
      keyFile: "/certs/${cert_file/.crt/.key}"
EOF
done
