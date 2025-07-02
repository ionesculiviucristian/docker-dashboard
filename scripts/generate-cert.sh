#!/bin/bash
set -eu 

hostname=$1
force=${2:-false}

if [ -z "${hostname}" ]; then
  echo "Error: Hostname is required"
  exit 1
fi

cert_file="./.certs/${hostname}.crt"
hosts_file="/etc/hosts"
key_file="./.certs/${hostname}.key"

if [[ -f "${cert_file}" && -f "${key_file}" && "${force}" = false ]]; then
  exit 0
fi

mkcert \
  -cert-file "${cert_file}" \
  -key-file "${key_file}" \
  "${hostname}" "*.${hostname}"

if ! grep -q "${hostname}" "${hosts_file}"; then
  echo "127.0.0.1 ${hostname}" | sudo tee -a "${hosts_file}" >/dev/null
fi

exit 0
