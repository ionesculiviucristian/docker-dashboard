#!/bin/bash
set -eu

# shellcheck source="./helpers.sh"
source "./scripts/helpers.sh"

if [ $# -ne 1 ]; then
  error_msg "Variable name is required"
  exit 1
fi

variable_name="$1"
env_file="./.env"
secret=$(openssl rand -base64 32)

if [ ! -f "${env_file}" ]; then
  error_msg "${env_file} not found"
  exit 1
fi

if grep -qE "^${variable_name}=(['\"]?)[^'\"[:space:]]+(\1)" "${env_file}"; then
  warning_msg "Variable ${variable_name} is already set"
elif grep -q "^${variable_name}=" "${env_file}"; then
  sed -i "s|^${variable_name}=.*|${variable_name}=\"${secret}\"|" "${env_file}"
  info_msg "Updated ${variable_name} variable"
else
  echo "${variable_name}=\"${secret}\"" >> "${env_file}"
  info_msg "Added ${variable_name} variable"
fi

exit 0
