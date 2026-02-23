#!/bin/bash
set -eu

# shellcheck source=../../../.env
set -a && source ".env" && set +a

# shellcheck source=../../../scripts/helpers.sh
source "./scripts/helpers.sh"

./scripts/create_docker_network.sh "${PROMETHEUS_NETWORK}"

./scripts/register_hostname.sh "prometheus.services.local"

exit 0
