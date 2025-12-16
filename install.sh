#!/bin/bash

set -eu 

cp "./.env.example" "./.env"

# shellcheck disable=SC1091
set -a && source "./.env" && set +a

# shellcheck disable=SC1091
source "./scripts/installer.sh"

# Install local certificate authority (CA)
if ! mkcert -CAROOT >/dev/null; then
  mkcert -install
fi

# Generate wildcard certificate for *.local.dev
mkcert \
  -cert-file "./services/nginx-proxy/certs/local.dev.crt" \
  -key-file "./services/nginx-proxy/certs/local.dev.key" \
  "*.local.dev" "local.dev"

# Create service networks
create_docker_network "${MAILPIT_NETWORK}"
create_docker_network "${MINIO_NETWORK}"
create_docker_network "${MONGO_NETWORK}"
create_docker_network "${MYSQL_NETWORK}"
create_docker_network "${NGINX_PROXY_NETWORK}"
create_docker_network "${POSTGRES_NETWORK}"
create_docker_network "${PROMETHEUS_NETWORK}"
create_docker_network "${RABBITMQ_NETWORK}"
create_docker_network "${REDIS_NETWORK}"

# Register service hosts to /etc/hosts
./scripts/register-host.sh cadvisor.local.dev
./scripts/register-host.sh homepage.local.dev
./scripts/register-host.sh it-tools.local.dev
./scripts/register-host.sh mailpit.local.dev
./scripts/register-host.sh minio.local.dev
./scripts/register-host.sh mongo-express.local.dev
./scripts/register-host.sh omni-tools.local.dev
./scripts/register-host.sh open-webui.local.dev
./scripts/register-host.sh pgadmin4.local.dev
./scripts/register-host.sh phpmyadmin.local.dev
./scripts/register-host.sh prometheus.local.dev
./scripts/register-host.sh rabbitmq.local.dev
./scripts/register-host.sh redisinsight.local.dev
./scripts/register-host.sh whatsupdocker.local.dev

# Add basic auth to services
./scripts/generate-htpasswd.sh cadvisor.local.dev
./scripts/generate-htpasswd.sh homepage.local.dev
./scripts/generate-htpasswd.sh it-tools.local.dev
./scripts/generate-htpasswd.sh omni-tools.local.dev
./scripts/generate-htpasswd.sh prometheus.local.dev
./scripts/generate-htpasswd.sh redisinsight.local.dev
./scripts/generate-htpasswd.sh whatsupdocker.local.dev

# Pre-setup services
./setups/pre/homepage.sh
./setups/pre/mongo.sh

# Setup services
docker compose up -d

# Post-setup services
setups/post/mongo.sh
setups/post/ollama.sh
setups/post/rabbitmq.sh

exit 0
