#!/bin/bash

set -eu 

# shellcheck disable=SC1091
set -a && source "./.env" && set +a

docker compose exec ollama ollama pull "${OLLAMA_MODEL}"

exit 0
