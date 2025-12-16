#!/bin/bash

set -eu 

[ -f "./services/mongo/keyfile" ] || (
  cd "./services/mongo"
  openssl rand -base64 756 > "./keyfile"
  chmod 400 "./keyfile"
  sudo chown 999:999 "./keyfile"
)

exit 0
