#!/bin/bash
set -eu

type="${1:-"base64"}"
shift || true
length=32
password=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --length)
      length="$2"
      shift 2
      ;;
    *)
      if [ "${type}" = "bcrypt" ] && [ -z "${password}" ]; then
        password="$1"
        shift
      else
        echo "Unknown option: $1"
        exit 1
      fi
      ;;
  esac
done

if [ "${type}" = "base64" ]; then
  bytes=$(( (length * 3 / 4) + 2 ))
  openssl rand -base64 "${bytes}" | tr -d '\n' | cut -c1-"${length}"
elif [ "${type}" = "bcrypt" ]; then
  if [ -z "${password}" ]; then
    echo "Password required for bcrypt"
    exit 1
  fi
  docker run --rm -i \
    httpd:2.4-alpine \
    htpasswd -nbB user "${password}" | \
  cut -d: -f2
else
  echo "Invalid type: ${type}"
  exit 1
fi

exit 0
