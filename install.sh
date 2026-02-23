#!/bin/bash
set -eu

source "./scripts/helpers.sh"

if [ "${1:-}" = "--reset" ]; then
  warning_msg "This will remove ALL docker containers, volumes, and networks (images will be kept)"
  read -r -p "Type 'yes' to continue: " confirmation

  if [ "${confirmation}" != "yes" ]; then
    info_msg "Aborted"
    exit 0
  fi

  ./scripts/reset_docker.sh
fi

info_msg "Start installing..."

[ -f "./.env" ] || cp "./.env.example" "./.env"

info_msg "Generating environment secrets..."

./scripts/generate_env_secret.sh "AUTHENTIK_BOOTSTRAP_TOKEN" | indent_msg
./scripts/generate_env_secret.sh "AUTHENTIK_SECRET_KEY" | indent_msg
./scripts/generate_env_secret.sh "OLLAMA_OPEN_WEBUI_WEBUI_SECRET_KEY" | indent_msg

set -a && source "./.env" && set +a

info_msg "Installing local certificate authority (CA)..."

if ! mkcert -CAROOT >/dev/null; then
  mkcert -install
fi

info_msg "Generating domain certs..."

./scripts/generate_domain_cert.sh "services.local" | indent_msg
./scripts/generate_domain_cert.sh "projects.local" | indent_msg

info_msg "Creating service networks..."

./scripts/create_docker_network.sh "${AUTHENTIK_NETWORK}" | indent_msg
./scripts/create_docker_network.sh "${GRAFANA_NETWORK}" | indent_msg
./scripts/create_docker_network.sh "${MAILPIT_NETWORK}" | indent_msg
./scripts/create_docker_network.sh "${MONGO_NETWORK}" | indent_msg
./scripts/create_docker_network.sh "${MYSQL_NETWORK}" | indent_msg
./scripts/create_docker_network.sh "${OLLAMA_NETWORK}" | indent_msg
./scripts/create_docker_network.sh "${POSTGRES_NETWORK}" | indent_msg
./scripts/create_docker_network.sh "${PROMETHEUS_NETWORK}" | indent_msg
./scripts/create_docker_network.sh "${PROXY_NETWORK}" | indent_msg
./scripts/create_docker_network.sh "${RABBITMQ_NETWORK}" | indent_msg
./scripts/create_docker_network.sh "${REDIS_NETWORK}" | indent_msg
./scripts/create_docker_network.sh "${SEAWEEDFS_NETWORK}" | indent_msg

info_msg "Registering hostnames..."

./scripts/register_hostname.sh "authentik.services.local" | indent_msg
./scripts/register_hostname.sh "cadvisor.services.local" | indent_msg
./scripts/register_hostname.sh "dozzle.services.local" | indent_msg
./scripts/register_hostname.sh "grafana.services.local" | indent_msg
./scripts/register_hostname.sh "grafana-alloy.services.local" | indent_msg
./scripts/register_hostname.sh "homepage.services.local" | indent_msg
./scripts/register_hostname.sh "it-tools.services.local" | indent_msg
./scripts/register_hostname.sh "mailpit.services.local" | indent_msg
./scripts/register_hostname.sh "mealie.services.local" | indent_msg
./scripts/register_hostname.sh "mongo-express.services.local" | indent_msg
./scripts/register_hostname.sh "n8n.services.local" | indent_msg
./scripts/register_hostname.sh "ntfy.services.local" | indent_msg
./scripts/register_hostname.sh "omni-tools.services.local" | indent_msg
./scripts/register_hostname.sh "open-webui.services.local" | indent_msg
./scripts/register_hostname.sh "pgadmin4.services.local" | indent_msg
./scripts/register_hostname.sh "phpmyadmin.services.local" | indent_msg
./scripts/register_hostname.sh "prometheus.services.local" | indent_msg
./scripts/register_hostname.sh "rabbitmq.services.local" | indent_msg
./scripts/register_hostname.sh "redisinsight.services.local" | indent_msg
./scripts/register_hostname.sh "seaweedfs.services.local" | indent_msg
./scripts/register_hostname.sh "traefik.services.local" | indent_msg
./scripts/register_hostname.sh "whatsupdocker.services.local" | indent_msg
./scripts/register_hostname.sh "whoami.services.local" | indent_msg

info_msg "Pre-setup services..."

info_msg "homepage" | indent_msg && ./setups/pre/homepage.sh | indent_msg 4
info_msg "MongoDB" | indent_msg && ./setups/pre/mongo.sh | indent_msg 4
info_msg "SeaweedFS" | indent_msg && ./setups/pre/seaweedfs.sh | indent_msg 4
info_msg "Traefik" | indent_msg && ./setups/pre/traefik.sh | indent_msg 4

info_msg "Starting services..."

if ! output=$(docker compose up -d 2>&1); then
  error_msg "${output}"
  exit 1
fi

info_msg "Post-setup services..."

info_msg "Authentik" | indent_msg && ./setups/post/authentik.sh | indent_msg 4
info_msg "Homepage" | indent_msg && ./setups/post/homepage.sh | indent_msg 4
info_msg "Mealie" | indent_msg && ./setups/post/mealie/setup.sh | indent_msg 4
info_msg "MongoDB" | indent_msg && ./setups/post/mongo.sh | indent_msg 4
info_msg "n8n" | indent_msg && ./setups/post/n8n.sh | indent_msg 4
info_msg "ntfy" | indent_msg && ./setups/post/ntfy/setup.sh | indent_msg 4
info_msg "Ollama" | indent_msg && ./setups/post/ollama.sh | indent_msg 4
info_msg "RabbitMQ" | indent_msg && ./setups/post/rabbitmq.sh | indent_msg 4

success_msg "Finished installing"

exit 0
