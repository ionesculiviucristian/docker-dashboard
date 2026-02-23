#!/bin/bash
set -eu

# shellcheck source=../../../.env
set -a && source ".env" && set +a

# shellcheck source=../../../scripts/helpers.sh
source "./scripts/helpers.sh"

./scripts/generate_env_secret.sh "OLLAMA_OPEN_WEBUI_WEBUI_SECRET_KEY"

./scripts/create_docker_network.sh "${OLLAMA_NETWORK}"

./scripts/register_hostname.sh "open-webui.services.local"

exit 0
