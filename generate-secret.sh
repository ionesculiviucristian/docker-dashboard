#!/bin/bash
set -eu 

if [ -z "$1" ]; then
  echo "Error: No file provided. Usage: $0 <file> [length]"
  exit 1
fi

FILE=".secrets/$1"
LENGTH="${2:-32}"

if [ -e "${FILE}" ]; then
  exit 0
fi

BYTES=$(( (LENGTH * 3 + 3) / 4 ))

if [ -n "${USE_DEV_PASSWORD}" ]; then
  if [ -f ".env" ]; then
    set -a
    source .env
    set +a

    SECRET="${DEV_PASSWORD}"
  else
    echo "Warning: USE_DEV_PASSWORD is set but .env file not found."
    exit 1
  fi
else
  BYTES=$(( (LENGTH * 3 + 3) / 4 ))
  SECRET=$(openssl rand -base64 "${BYTES}" | tr -d '\n' | cut -c1-"${LENGTH}")
fi

echo "${SECRET}" > "${FILE}"
