#!/bin/bash
set -eu

# shellcheck source=../../../.env
set -a && source ".env" && set +a

# shellcheck source=../../../scripts/helpers.sh
source "./scripts/helpers.sh"

./scripts/generate_env_secret.sh "AUTHENTIK_BOOTSTRAP_TOKEN"
./scripts/generate_env_secret.sh "AUTHENTIK_SECRET_KEY"

./scripts/create_docker_network.sh "${AUTHENTIK_NETWORK}"

./scripts/register_hostname.sh "authentik.services.local"

exit 0
