#!/bin/bash
set -eu

# shellcheck source=../../../.env
set -a && source ".env" && set +a

# shellcheck source=../../../scripts/helpers.sh
source "./scripts/helpers.sh"

./scripts/create_docker_network.sh "${GRAFANA_NETWORK}"

./scripts/register_hostname.sh "grafana.services.local"
./scripts/register_hostname.sh "grafana-alloy.services.local"

exit 0
