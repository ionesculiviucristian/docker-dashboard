#!/bin/bash
set -eu 

cp "./.env.example" "./.env"

# Generate secrets
./scripts/generate_secret.sh "AUTHENTIK_BOOTSTRAP_TOKEN"
./scripts/generate_secret.sh "AUTHENTIK_SECRET_KEY"
./scripts/generate_secret.sh "OLLAMA_OPEN_WEBUI_WEBUI_SECRET_KEY"

set -a && source "./.env" && set +a

# Install local certificate authority (CA)
if ! mkcert -CAROOT >/dev/null; then
  mkcert -install
fi

# Generate domain certs
./scripts/generate_domain_cert.sh "services.local"
./scripts/generate_domain_cert.sh "projects.local"

# Create service networks
./scripts/create_docker_network.sh "${MAILPIT_NETWORK}"
./scripts/create_docker_network.sh "${MINIO_NETWORK}"
./scripts/create_docker_network.sh "${MONGO_NETWORK}"
./scripts/create_docker_network.sh "${MYSQL_NETWORK}"
./scripts/create_docker_network.sh "${POSTGRES_NETWORK}"
./scripts/create_docker_network.sh "${PROMETHEUS_NETWORK}"
./scripts/create_docker_network.sh "${PROXY_NETWORK}"
./scripts/create_docker_network.sh "${RABBITMQ_NETWORK}"
./scripts/create_docker_network.sh "${REDIS_NETWORK}"

# Register service hostnames
./scripts/register_hostname.sh "authentik.services.local"
./scripts/register_hostname.sh "cadvisor.services.local"
./scripts/register_hostname.sh "grafana.services.local"
./scripts/register_hostname.sh "grafana-alloy.services.local"
./scripts/register_hostname.sh "homepage.services.local"
./scripts/register_hostname.sh "it-tools.services.local"
./scripts/register_hostname.sh "mailpit.services.local"
./scripts/register_hostname.sh "mealie.services.local"
./scripts/register_hostname.sh "minio.services.local"
./scripts/register_hostname.sh "mongo-express.services.local"
./scripts/register_hostname.sh "n8n.services.local"
./scripts/register_hostname.sh "omni-tools.services.local"
./scripts/register_hostname.sh "open-webui.services.local"
./scripts/register_hostname.sh "pgadmin4.services.local"
./scripts/register_hostname.sh "phpmyadmin.services.local"
./scripts/register_hostname.sh "prometheus.services.local"
./scripts/register_hostname.sh "rabbitmq.services.local"
./scripts/register_hostname.sh "redisinsight.services.local"
./scripts/register_hostname.sh "traefik.services.local"
./scripts/register_hostname.sh "whatsupdocker.services.local"
./scripts/register_hostname.sh "whoami.services.local"

# Pre-setup services
./setups/pre/homepage.sh
./setups/pre/mongo.sh

# Generate dynamic Traefik config
./scripts/generate_traefik_dynamic_config.sh

# Start services
docker compose up -d

# Post-setup services
./setups/post/mongo.sh
./setups/post/ollama.sh
./setups/post/rabbitmq.sh

exit 0
