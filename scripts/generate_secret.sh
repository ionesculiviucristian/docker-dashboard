#!/bin/bash
set -eu

if [ $# -ne 1 ]; then
  echo "Error: Variable name is required"
  exit 1
fi

variable_name="$1"
env_file="./.env"
secret=$(openssl rand -base64 32)

if grep -q "^${variable_name}=" "${env_file}"; then
  sed -i "s|^${variable_name}=.*|${variable_name}=\"${secret}\"|" "${env_file}"
else
  echo "${variable_name}=\"${secret}\"" >> "${env_file}"
fi

exit 0
