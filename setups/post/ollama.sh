#!/bin/bash
set -eu 

# shellcheck source=../../.env
set -a && source "./.env" && set +a

docker compose exec ollama ollama pull "${OLLAMA_MODEL}"

exit 0
