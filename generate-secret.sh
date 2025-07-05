#!/bin/bash
set -eu 

SECRET_FILE=""
LENGTH=32
SECRET=""
FORCE=false

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <file> [--length <number>] [--secret <value>] [--force]"
  exit 1
fi

SECRET_FILE=".secrets/$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --length)
      LENGTH="$2"
      shift 2
      ;;
    --secret)
      SECRET="$2"
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

if [[ -f "${SECRET_FILE}" && "${FORCE}" = false ]]; then
  exit 0
fi

if [ -z "${SECRET}" ]; then
  BYTES=$(((LENGTH * 3 + 3) / 4))
  SECRET=$(openssl rand -base64 "${BYTES}" | tr -d '\n' | cut -c1-"${LENGTH}")
fi

echo "${SECRET}" > "${SECRET_FILE}"

exit 0
