#!/bin/bash
set -eu 

#shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

keyfile="./services/mongo/keyfile"

if [ -f "${keyfile}" ]; then
  debug_msg "Keyfile already exists"
else
  openssl rand -base64 756 > "${keyfile}"
  chmod 400 "${keyfile}"
  sudo chown 999:999 "${keyfile}"

  debug_msg "Created keyfile"
fi

exit 0
