#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source "./.env" && set +a

echo "Waiting for Ollama to be ready..."
until docker compose exec ollama ollama list >/dev/null 2>&1; do
  echo -n "."
  sleep 2
done

docker compose exec ollama ollama pull "${OLLAMA_MODEL}"

exit 0
