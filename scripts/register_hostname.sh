#!/bin/bash
set -eu

if [ $# -ne 1 ]; then
  echo "Error: Hostname is required"
  exit 1
fi

hostname="$1"
hosts_file="/etc/hosts"

if ! grep -q "${hostname}" "${hosts_file}"; then
  echo "127.0.0.1 ${hostname}" | sudo tee -a "${hosts_file}" >/dev/null
  echo -e "\u2705 Registered ${hostname} hostname"
else
  echo -e "\u2139 Hostname ${hostname} is already registered"
fi

exit 0
