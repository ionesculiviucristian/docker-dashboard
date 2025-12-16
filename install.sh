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

# Create docker networks
create_docker_network "${MAILPIT_NETWORK}"
create_docker_network "${MINIO_NETWORK}"
create_docker_network "${MONGO_NETWORK}"
create_docker_network "${MYSQL_NETWORK}"
create_docker_network "${NGINX_PROXY_NETWORK}"
create_docker_network "${POSTGRES_NETWORK}"
create_docker_network "${PROMETHEUS_NETWORK}"
create_docker_network "${RABBITMQ_NETWORK}"
create_docker_network "${REDIS_NETWORK}"

# Register services to /etc/hosts
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

# homepage
touch "./services/homepage/config/bookmarks.yaml"

# mongo-express
[ -f "./services/mongo/keyfile" ] || (
  cd "./services/mongo"
  openssl rand -base64 756 > "./keyfile"
  chmod 400 "./keyfile"
  sudo chown 999:999 "./keyfile"
)

# Start services
docker compose up -d

echo "Waiting for MongoDB to be ready..."
until docker compose exec mongo mongosh --eval "db.adminCommand('ping')" >/dev/null 2>&1; do
  echo -n "."
  sleep 2
done

docker compose exec mongo mongosh \
  -u "${SERVICES_USER}" \
  -p "${SERVICES_USER_PASSWORD}" \
  --eval 'rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "mongo:27017" }] })'

docker compose exec rabbitmq rabbitmq-plugins enable rabbitmq_prometheus

docker compose exec ollama ollama pull "${OLLAMA_MODEL}"

exit 0
