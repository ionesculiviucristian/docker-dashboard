#!/bin/bash
set -eu

# shellcheck source="./helpers.sh"
source "./scripts/helpers.sh"

if [ $# -ne 1 ]; then
  error_msg "Hostname is required"
  exit 1
fi

hostname="$1"
hosts_file="/etc/hosts"

info_msg "Registering ${hostname} hostname..." true

if ! grep -q "${hostname}" "${hosts_file}"; then
  if output=$(echo "127.0.0.1 ${hostname}" | sudo tee -a "${hosts_file}" 2>&1); then
    status_ok
  else
    status_fail "${output}"
  fi
else
  status_skip
fi

exit 0
