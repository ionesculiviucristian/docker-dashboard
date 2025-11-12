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

# cAdvisor
./scripts/generate-cert.sh cadvisor.localdev
./scripts/generate-htpasswd.sh cadvisor.localdev

# homepage
touch "./services/homepage/config/bookmarks.yaml"

./scripts/generate-cert.sh homepage.localdev
./scripts/generate-htpasswd.sh homepage.localdev

# IT - TOOLS
./scripts/generate-cert.sh it-tools.localdev
./scripts/generate-htpasswd.sh it-tools.localdev

# Mailpit
./scripts/generate-cert.sh mailpit.localdev

# MinIO
./scripts/generate-cert.sh minio.localdev

# mongo-express
./scripts/generate-cert.sh mongo-express.localdev

[ -f "./services/mongo/keyfile" ] || (
  cd "./services/mongo"
  openssl rand -base64 756 > "./keyfile"
  chmod 400 "./keyfile"
  sudo chown 999:999 "./keyfile"
)

# nginx-proxy

# Omni Tools
./scripts/generate-cert.sh omni-tools.localdev

# pgadmin4
./scripts/generate-cert.sh pgadmin4.localdev

# phpmyadmin
./scripts/generate-cert.sh phpmyadmin.localdev

# Prometheus
./scripts/generate-cert.sh prometheus.localdev

# RabbitMQ
./scripts/generate-cert.sh rabbitmq.localdev

# Redis Insight
./scripts/generate-cert.sh redisinsight.localdev
./scripts/generate-htpasswd.sh redisinsight.localdev

# What's up Docker?
./scripts/generate-cert.sh whatsupdocker.localdev
./scripts/generate-htpasswd.sh whatsupdocker.localdev

# Start services
docker compose up -d

docker compose exec mongo mongosh \
  -u "${SERVICES_USER}" \
  -p "${SERVICES_USER_PASSWORD}" \
  --eval 'rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "mongo:27017" }] })'

docker compose exec rabbitmq rabbitmq-plugins enable rabbitmq_prometheus

exit 0
