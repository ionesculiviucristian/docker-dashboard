<!-- markdownlint-disable MD033 -->

# Services

## Pre docker compose setup

[Install mkcert](https://github.com/FiloSottile/mkcert?tab=readme-ov-file#linux)

```bash
mkcert -install

sudo pacman -Syu dnsmasq

sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

echo "[main]" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
echo "dns=none" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
echo "rc-manager=unmanaged" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
sudo systemctl restart NetworkManager

ls -lh /etc/resolv.conf
sudo rm /etc/resolv.conf

echo "nameserver 127.0.0.1" | sudo tee -a /etc/resolv.conf
echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf

sudo mkdir /etc/resolver

echo "address=/.localdev/127.0.0.1" | sudo tee -a /etc/dnsmasq.conf
echo "listen-address=127.0.0.1" | sudo tee -a /etc/dnsmasq.conf
echo "nameserver 127.0.0.1" | sudo tee -a /etc/resolver/localdev
sudo systemctl restart dnsmasq
```

```bash
cd ~/Projects
git clone https://github.com/ionesculiviucristian/docker-dashboard.git
cp .env.example .env
```

## nginx-proxy [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/jwilder/nginx-proxy) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/nginx-proxy/nginx-proxy/blob/main/Dockerfile.debian)

```bash
cd ~/Projects/services
( set -a; source .env; set +a; docker network create "$NGINX_PROXY_NETWORK" )
```

## [cAdvisor](https://cadvisor.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/google/cadvisor) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/google/cadvisor/blob/master/deploy/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh cadvisor.localdev
./generate-htpasswd.sh cadvisor.localdev
```

## [GeoServer](https://geoserver.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://docker.osgeo.org/#browse/browse:geoserver-docker) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/geoserver/docker/blob/master/Dockerfile)

### Postgres with PostGIS [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/postgis/postgis) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/postgis/docker-postgis/blob/master/17-3.5/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh geoserver.localdev
```

## [Grafana](https://grafana.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/grafana/grafana) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/grafana/grafana/blob/main/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh grafana.localdev
```

## [homepage](https://homepage.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/gethomepage/homepage) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/gethomepage/homepage/blob/dev/Dockerfile)

Photo by [Viktor Hanacek](https://picjumbo.com/author/viktorhanacek/) from [picjumbo.com](picjumbo.com)

```bash
cd ~/Projects/services
./generate-cert.sh homepage.localdev
./generate-htpasswd.sh homepage.localdev
```

## [IT - TOOLS](https://it-tools.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/corentinth/it-tools) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/CorentinTh/it-tools/blob/main/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh it-tools.localdev
./generate-htpasswd.sh it-tools.localdev
```

## [Mailpit](https://mailpit.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/axllent/mailpit) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/axllent/mailpit/blob/master/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh mailpit.localdev
```

## [MinIO](https://minio.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/minio/minio) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/minio/minio/blob/master/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh minio.localdev
```

## MongoDB [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/_/mongo) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/docker-library/mongo/blob/master/8.0/Dockerfile)

### [mongo-express](https://mongo-express.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/_/mongo-express) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/mongo-express/mongo-express/blob/master/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh mongo-express.localdev

cd ~/Projects/services/mongo
openssl rand -base64 756 > keyfile
chmod 400 keyfile
sudo chown 999:999 keyfile
```

## MySQL [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/_/mysql) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/docker-library/mysql/blob/master/innovation/Dockerfile.oracle)

### [phpMyAdmin](https://phpmyadmin.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/_/phpmyadmin) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/phpmyadmin/docker/blob/master/apache/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh phpmyadmin.localdev
./generate-secret.sh MYSQL_ROOT_PASSWORD
USE_DEV_PASSWORD=true ./generate-secret.sh MYSQL_DEV_PASSWORD

```

## [Omni Tools](https://omni-tools.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/iib0011/omni-tools) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/iib0011/omni-tools/blob/main/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh omni-tools.localdev
```

## [Planka](https://planka.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://github.com/plankanban/planka/pkgs/container/planka) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/plankanban/planka/blob/master/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh planka.localdev
```

## [Prometheus](https://planka.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/prom/prometheus) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/prometheus/prometheus/blob/main/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh prometheus.localdev
./generate-htpasswd.sh prometheus.localdev
```

## PostgreSQL [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/_/postgres) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/docker-library/postgres/blob/master/17/bookworm/Dockerfile)

### [pgadmin4](https://pgadmin4.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/dpage/pgadmin4) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/pgadmin-org/pgadmin4/blob/master/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh pgadmin4.localdev
./generate-secret.sh POSTGRES_PASSWORD
USE_DEV_PASSWORD=true ./generate-secret.sh POSTGRES_DEV_PASSWORD
```

## [RabbitMQ](https://rabbitmq.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/_/rabbitmq) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/docker-library/rabbitmq/blob/master/4.0/alpine/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh rabbitmq.localdev
```

## Redis [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/_/redis) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/redis/docker-library-redis/blob/master/7.4/alpine/Dockerfile)

### [Redis Insight](https://redisinsight.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/redis/redisinsight) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/RedisInsight/RedisInsight/blob/main/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh redisinsight.localdev
./generate-htpasswd.sh redisinsight.localdev
```

## [What's up Docker?](https://whatsupdocker.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/getwud/wud) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/getwud/wud/blob/main/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh whatsupdocker.localdev
./generate-htpasswd.sh whatsupdocker.localdev
```

# Misc

## [AdGuard Home](https://adguardhome.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/adguard/adguardhome) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/AdguardTeam/AdGuardHome/blob/master/docker/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh adguardhome.localdev
```

## [Bitwarden](https://bitwarden.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://github.com/bitwarden/self-host/pkgs/container/self-host) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/bitwarden/self-host/blob/main/docker-unified/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh bitwarden.localdev
```

## [GitLab](https://gitlab.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/gitlab/gitlab-ce/)

### GitLab Runner [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/gitlab/gitlab-runner)

```bash
cd ~/Projects/services
./generate-cert.sh gitlab.localdev
```

## [Healthchecks](https://healthchecks.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/healthchecks/healthchecks) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/healthchecks/healthchecks/blob/master/docker/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh healthchecks.localdev
```

## [MiroTalk](https://mirotalk.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/mirotalk/p2p) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/miroslavpejic85/mirotalk/blob/master/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh mirotalk.localdev
```

## [Kimai](https://kimai.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/kimai/kimai2) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/kimai/kimai/blob/main/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh kimai.localdev
```

## [Linkwarden](https://linkwarden.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://github.com/linkwarden/linkwarden/pkgs/container/linkwarden) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/linkwarden/linkwarden/blob/main/Dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh linkwarden.localdev
```

## [ownCloud](https://owncloud.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/owncloud/server/) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/owncloud-docker/server/blob/master/v20.04/Dockerfile.multiarch)

```bash
cd ~/Projects/services
./generate-cert.sh owncloud.localdev
```

## [Uptime Kuma](https://uptime-kuma.localdev) [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/louislam/uptime-kuma) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/louislam/uptime-kuma/blob/master/docker/dockerfile)

```bash
cd ~/Projects/services
./generate-cert.sh uptime-kuma.localdev
```

## Post docker compose setup

```bash
cd ~/Projects/services
docker compose up -d

docker compose exec mongo mongosh -u developer --eval 'rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "mongo:27017" }] })'

docker compose exec mysql mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT CREATE, ALTER, DROP ON *.* TO 'developer'@'%'; FLUSH PRIVILEGES"

docker compose exec healthchecks /opt/healthchecks/manage.py createsuperuser
```

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" integrity="sha512-Evv84Mr4kqVGRNSgIGL/F/aIDqQb7xQ2vcrdIwxfjThSH8CSR7PBEakCr51Ck+w+/U6swU2Im1vVX0SVk9ABhg==" crossorigin="anonymous" referrerpolicy="no-referrer" />

## Creating and updating Grafana dashboards

```bash
yay -Syu --needed --noconfirm go-jsonnet jsonnet-bundler
cd ./grafana/src/dashboards
go install
./build-dashboards.sh
```
