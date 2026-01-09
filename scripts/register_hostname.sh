#!/bin/bash
set -eu

#shellcheck source="./helpers.sh"
source "./scripts/helpers.sh"

if [ $# -ne 1 ]; then
  error_msg "Hostname is required"
  exit 1
fi

hostname="$1"
hosts_file="/etc/hosts"

if ! grep -q "${hostname}" "${hosts_file}"; then
  echo "127.0.0.1 ${hostname}" | sudo tee -a "${hosts_file}" >/dev/null
  success_msg "Registered ${hostname} hostname"
else
  info_msg "Hostname ${hostname} is already registered"
fi

exit 0
