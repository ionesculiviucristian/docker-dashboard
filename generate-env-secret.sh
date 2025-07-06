#!/bin/bash
set -eu

ENV_KEY=""
ENV_FILE=".env"

LENGTH=32
SECRET_VALUE=""
FORCE=false

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <ENV_KEY> [--length <number>] [--secret <value>] [--force]"
  echo ""
  echo "  <ENV_KEY>       The name of the environment variable to update"
  echo "  --length <num>  Generate a secret of this length (default: 32)"
  echo "  --secret <val>  Use this explicit secret value instead of generating one"
  echo "  --force         Force update the secret even if it already exists"
  exit 1
fi

ENV_KEY="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --length)
      LENGTH="$2"
      shift 2
      ;;
    --secret)
      SECRET_VALUE="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [ ! -f "${ENV_FILE}" ]; then
  echo "Error: .env file not found at '${ENV_FILE}'."
  exit 1
fi

if [ -z "${SECRET_VALUE}" ]; then
  BYTES=$(( (LENGTH * 3 / 4) + 2 ))
  SECRET_VALUE=$(openssl rand -base64 "${BYTES}" | tr -d '\n' | cut -c1-"${LENGTH}")
fi

if grep -qE "^${ENV_KEY}=" "${ENV_FILE}"; then
  if [ "${FORCE}" = false ]; then
    exit 0
  else
    sed -i -E "s|^(${ENV_KEY}=).*|\1\"${SECRET_VALUE}\"|" "${ENV_FILE}"
  fi
else
  echo "Warning: Key '${ENV_KEY}' not found in '${ENV_FILE}'. No update performed."
  exit 1
fi

exit 0
