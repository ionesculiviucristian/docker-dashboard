#!/bin/bash
# shellcheck disable=SC2329
set -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
GREY='\033[0;90m'
NC='\033[0m'

success_msg() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

info_msg() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

warning_msg() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

error_msg() {
  echo -e "${RED}[ERROR]${NC} $1"
}

debug_msg() {
  echo -e "${GREY}[DEBUG]${NC} $1"
}

indent_msg() {
  local count="${1:-2}"
  local padding=""
  
  for ((i=0; i<count; i++)); do
    padding+=" "
  done

  sed "s/^/${padding}/"
}

wait_for_service() {
  local container=$1
  local cmd=$2
  local timeout=${3:-60}
  local elapsed=0

  info_msg "Waiting for ${container} service to be ready"

  until docker compose exec "${container}" sh -c "${cmd}" &>/dev/null; do
    echo -n "."
    sleep 2
    elapsed=$((elapsed + 2))

    if [ ${elapsed} -ge "${timeout}" ]; then
      echo ""
      error_msg "Timeout waiting for ${container} service to be ready after ${timeout} seconds"
      exit 1
    fi
  done
}
