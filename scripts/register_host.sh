#!/bin/bash
set -eu

hostname=$1

if [ -z "${hostname}" ]; then
  echo "Error: Hostname is required"
  exit 1
fi

hosts_file="/etc/hosts"

if ! grep -q "${hostname}" "${hosts_file}"; then
  echo "127.0.0.1 ${hostname}" | sudo tee -a "${hosts_file}" >/dev/null
fi

exit 0
