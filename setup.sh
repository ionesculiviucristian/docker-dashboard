#!/bin/bash
# shellcheck disable=SC2046
set -eu 

set -a
# shellcheck disable=SC1091
source .env
set +a

reset_docker() {
    docker stop $(docker ps -aq) 
    docker rm -v $(docker ps -aq)
    docker network prune -f
    docker volume rm $(docker volume ls -q)

    # docker image prune -a -f
    # docker builder prune -a -f

    # docker system prune -a --volumes -f

    # docker image ls -a \
    #     && docker container ls -a \
    #     && docker volume ls \
    #     && docker network ls
}

create_docker_network() {
  local name="$1"
  if ! docker network inspect "${name}" >/dev/null 2>&1; then
    docker network create "${name}"
  fi
}

# Install local certificate authority (CA)
mkcert -install

# Create docker networks
create_docker_network "$BITWARDEN_NETWORK"
create_docker_network "$CADVISOR_NETWORK"
create_docker_network "$GEOSERVER_NETWORK"
create_docker_network "$GITLAB_NETWORK"
create_docker_network "$GRAFANA_NETWORK"
create_docker_network "$HEALTHCHECKS_NETWORK"
create_docker_network "$KIMAI_NETWORK"
create_docker_network "$LINKWARDEN_NETWORK"
create_docker_network "$MAILPIT_NETWORK"
create_docker_network "$MINIO_NETWORK"
create_docker_network "$MONGO_NETWORK"
create_docker_network "$MYSQL_NETWORK"
create_docker_network "$NGINX_PROXY_NETWORK"
create_docker_network "$OWNCLOUD_NETWORK"
create_docker_network "$PLANKA_NETWORK"
create_docker_network "$POSTGRES_NETWORK"
create_docker_network "$PROMETHEUS_NETWORK"
create_docker_network "$RABBITMQ_NETWORK"
create_docker_network "$REDIS_NETWORK"

# AdGuard Home
./generate-cert.sh adguardhome.localdev

# Bitwarden
./generate-cert.sh bitwarden.localdev

# cAdvisor
./generate-cert.sh cadvisor.localdev
./generate-htpasswd.sh cadvisor.localdev

# GeoServer
./generate-cert.sh geoserver.localdev

# GitLab
./generate-cert.sh gitlab.localdev

# Grafana
./generate-cert.sh grafana.localdev

# Healthchecks
./generate-cert.sh healthchecks.localdev

# homepage
./generate-cert.sh homepage.localdev
./generate-htpasswd.sh homepage.localdev

# IT - TOOLS
./generate-cert.sh it-tools.localdev
./generate-htpasswd.sh it-tools.localdev

# Kimai
./generate-cert.sh kimai.localdev

# Linkwarden
./generate-cert.sh linkwarden.localdev

# Mailpit
./generate-cert.sh mailpit.localdev

# MinIO
./generate-cert.sh minio.localdev

# MiroTalk
./generate-cert.sh mirotalk.localdev

# mongo-express
./generate-cert.sh mongo-express.localdev

[ -f "./services/mongo/keyfile" ] || (
  cd "./services/mongo"
  openssl rand -base64 756 > "./keyfile"
  chmod 400 "./keyfile"
  sudo chown 999:999 "./keyfile"
)

# nginx-proxy

# Omni Tools
./generate-cert.sh omni-tools.localdev

# ownCloud
./generate-cert.sh owncloud.localdev

# pgadmin4
./generate-cert.sh pgadmin4.localdev
./generate-secret.sh POSTGRES_PASSWORD
./generate-secret.sh POSTGRES_SERVICES_USER_PASSWORRD --secret "${SERVICES_USER_PASSWORRD}"

# phpmyadmin
./generate-cert.sh phpmyadmin.localdev
./generate-secret.sh MYSQL_ROOT_PASSWORD
./generate-secret.sh MYSQL_SERVICES_USER_PASSWORRD --secret "${SERVICES_USER_PASSWORRD}"

# Planka
./generate-cert.sh planka.localdev

# Prometheus
./generate-cert.sh prometheus.localdev
./generate-htpasswd.sh prometheus.localdev

# RabbitMQ
./generate-cert.sh rabbitmq.localdev

# Redis Insight
./generate-cert.sh redisinsight.localdev
./generate-htpasswd.sh redisinsight.localdev

# Uptime Kuma
./generate-cert.sh uptime-kuma.localdev

# What's up Docker?
./generate-cert.sh whatsupdocker.localdev
./generate-htpasswd.sh whatsupdocker.localdev

# Start services
docker compose up -d

docker compose exec mongo mongosh -u "$SERVICES_USER" -p "$SERVICES_USER_PASSWORRD" --eval '
if (rs.status().ok === 0) {
  rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "mongo:27017" }] });
}
'
# TODO: add command for creating the user
# docker compose exec healthchecks /opt/healthchecks/manage.py createsuperuser
