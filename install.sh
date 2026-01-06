#!/bin/bash

set -eu 

# shellcheck disable=SC1091
source "./scripts/installer.sh"

cp "./.env.example" "./.env"

./scripts/generate_secret.sh "AUTHENTIK_SECRET_KEY"
./scripts/generate_secret.sh "OLLAMA_OPEN_WEBUI_WEBUI_SECRET_KEY"

# shellcheck disable=SC1091
set -a && source "./.env" && set +a

# Install local certificate authority (CA)
if ! mkcert -CAROOT >/dev/null; then
  mkcert -install
fi

# Generate wildcard certificates
./scripts/generate_cert.sh "services"
./scripts/generate_cert.sh "projects"

# Create service networks
create_docker_network "${MAILPIT_NETWORK}"
create_docker_network "${MINIO_NETWORK}"
create_docker_network "${MONGO_NETWORK}"
create_docker_network "${MYSQL_NETWORK}"
create_docker_network "${POSTGRES_NETWORK}"
create_docker_network "${PROMETHEUS_NETWORK}"
create_docker_network "${PROXY_NETWORK}"
create_docker_network "${RABBITMQ_NETWORK}"
create_docker_network "${REDIS_NETWORK}"

# Register service domains to /etc/hosts
./scripts/register_host.sh "authentik.services.local"
./scripts/register_host.sh "cadvisor.services.local"
./scripts/register_host.sh "homepage.services.local"
./scripts/register_host.sh "it-tools.services.local"
./scripts/register_host.sh "mailpit.services.local"
./scripts/register_host.sh "mealie.services.local"
./scripts/register_host.sh "minio.services.local"
./scripts/register_host.sh "mongo-express.services.local"
./scripts/register_host.sh "n8n.services.local"
./scripts/register_host.sh "omni-tools.services.local"
./scripts/register_host.sh "open-webui.services.local"
./scripts/register_host.sh "pgadmin4.services.local"
./scripts/register_host.sh "phpmyadmin.services.local"
./scripts/register_host.sh "prometheus.services.local"
./scripts/register_host.sh "rabbitmq.services.local"
./scripts/register_host.sh "redisinsight.services.local"
./scripts/register_host.sh "traefik.services.local"
./scripts/register_host.sh "whatsupdocker.services.local"
./scripts/register_host.sh "whoami.services.local"

# Pre-setup services
./setups/pre/homepage.sh
./setups/pre/mongo.sh

./scripts/generate_traefik.sh

# Setup services
docker compose up -d

# Post-setup services
./setups/post/mongo.sh
./setups/post/ollama.sh
./setups/post/rabbitmq.sh

exit 0
