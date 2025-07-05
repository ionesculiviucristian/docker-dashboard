<!-- markdownlint-disable MD033 -->

# Services

## Pre docker compose setup

[Install mkcert](https://github.com/FiloSottile/mkcert?tab=readme-ov-file#linux)

```bash

```

```bash
cd ~/Projects
git clone https://github.com/ionesculiviucristian/docker-dashboard.git
cp .env.example .env
```

## List of available services

- [AdGuard Home](https://adguardhome.localdev): AdGuard Home is a network-wide software for blocking ads & tracking [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/adguard/adguardhome) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/AdguardTeam/AdGuardHome/blob/master/docker/Dockerfile)
- [Bitwarden](https://bitwarden.localdev): Bitwarden is the best password manager for securely storing, managing, and sharing sensitive information such as passwords, passkeys, and credit cards [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://github.com/bitwarden/self-host/pkgs/container/self-host) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/bitwarden/self-host/blob/main/docker-unified/Dockerfile)
- [cAdvisor](https://cadvisor.localdev): Analyzes resource usage and performance characteristics of running containers [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/google/cadvisor) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/google/cadvisor/blob/master/deploy/Dockerfile)
- [GeoServer](https://geoserver.localdev): GeoServer is an open source server for sharing geospatial data [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://docker.osgeo.org/#browse/browse:geoserver-docker) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/geoserver/docker/blob/master/Dockerfile)
- [GitLab](https://gitlab.localdev): undefined [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/gitlab/gitlab-ce) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://gitlab.com/gitlab-org/gitlab/-/blob/master/Dockerfile.assets)
- [Grafana](https://grafana.localdev): The open and composable observability and data visualization platform [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/grafana/grafana) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/grafana/grafana/blob/main/Dockerfile)
- [Healthchecks](https://healthchecks.localdev): Open-source cron job and background task monitoring service, written in Python & Django [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/healthchecks/healthchecks) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/healthchecks/healthchecks/blob/master/docker/Dockerfile)
- [homepage](https://homepage.localdev): A highly customizable homepage (or startpage / application dashboard) with Docker and service API integrations [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/gethomepage/homepage) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/gethomepage/homepage/blob/dev/Dockerfile)
- [IT - TOOLS](https://it-tools.localdev): Collection of handy online tools for developers, with great UX [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/corentinth/it-tools) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/CorentinTh/it-tools/blob/main/Dockerfile)
- [Kimai](https://kimai.localdev): Kimai is a web-based multi-user time-tracking application [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/kimai/kimai2) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/kimai/kimai/blob/main/Dockerfile)
- [Linkwarden](https://linkwarden.localdev): elf-hosted collaborative bookmark manager to collect, organize, and preserve webpages, articles, and documents [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://github.com/linkwarden/linkwarden/pkgs/container/linkwarden) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/linkwarden/linkwarden/blob/main/Dockerfile)
- [Mailpit](https://mailpit.localdev): An email and SMTP testing tool with API for developers [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/axllent/mailpit) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/axllent/mailpit/blob/master/Dockerfile)
- [MinIO](https://minio.localdev): MinIO is a high-performance, S3 compatible object store, open sourced under GNU AGPLv3 license [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/minio/minio) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/minio/minio/blob/master/Dockerfile)
- [MiroTalk](https://mirotalk.localdev): WebRTC - P2P - Simple, Secure, Fast Real-Time Video Conferences Up to 8k and 60fps, compatible with all browsers and platforms [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/mirotalk/p2p) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/miroslavpejic85/mirotalk/blob/master/Dockerfile)
- [mongo-express](https://mongo-express.localdev): Web-based MongoDB admin interface, written with Node.js and Express [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/_/mongo-express) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/mongo-express/mongo-express/blob/master/Dockerfile)
- [nginx-proxy](https://adguardhome.localdev): Automated Nginx reverse proxy for docker containers [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/jwilder/nginx-proxy) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/nginx-proxy/nginx-proxy/blob/main/Dockerfile.debian)
- [Omni Tools](https://omni-tools.localdev): Self-hosted collection of powerful web-based tools for everyday tasks. No ads, no tracking, just fast, accessible utilities right from your browser! [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/iib0011/omni-tools) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/iib0011/omni-tools/blob/main/Dockerfile)
- [ownCloud](https://owncloud.localdev): ownCloud enables you to share and sync data and keep it safe at the same time, on all platforms [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/owncloud/server) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/owncloud-docker/server/blob/master/v20.04/Dockerfile.multiarch)
- [pgadmin4](https://pgadmin4.localdev): pgAdmin is the most popular and feature rich Open Source administration and development platform for PostgreSQL, the most advanced Open Source database in the world [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/dpage/pgadmin4) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/pgadmin-org/pgadmin4/blob/master/Dockerfile)
- [phpMyAdmin](https://phpmyadmin.localdev): A web interface for MySQL and MariaDB [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/_/phpmyadmin) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/phpmyadmin/docker/blob/master/apache/Dockerfile)
- [Planka](https://planka.localdev): PLANKA is the kanban-style project mastering tool for everyone [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://github.com/plankanban/planka/pkgs/container/planka) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/plankanban/planka/blob/master/Dockerfile)
- [Prometheus](https://prometheus.localdev): The Prometheus monitoring system and time series database [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/prom/prometheus) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/prometheus/prometheus/blob/main/Dockerfile)
- [RabbitMQ](https://rabbitmq.localdev): RabbitMQ is a reliable and mature messaging and streaming broker, which is easy to deploy on cloud environments, on-premises, and on your local machine. It is currently used by millions worldwide [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/_/rabbitmq) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/docker-library/rabbitmq/blob/master/4.0/alpine/Dockerfile)
- [Redis Insight](https://redisinsight.localdev): Redis GUI by Redis [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/redis/redisinsight) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/RedisInsight/RedisInsight/blob/main/Dockerfile)
- [Uptime Kuma](https://uptime-kuma.localdev):  Afancy self-hosted monitoring tool [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/louislam/uptime-kuma) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/louislam/uptime-kuma/blob/master/docker/dockerfile)
- [What's up Docker?](https://whatsupdocker.localdev): Keep your containers up-to-date! [<i class="fa-brands fa-docker" title="Docker Hub"></i>](https://hub.docker.com/r/getwud/wud) [<i class="fa fa-file-code" title="Dockerfile"></i>](https://github.com/getwud/wud/blob/main/Dockerfile)

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" integrity="sha512-Evv84Mr4kqVGRNSgIGL/F/aIDqQb7xQ2vcrdIwxfjThSH8CSR7PBEakCr51Ck+w+/U6swU2Im1vVX0SVk9ABhg==" crossorigin="anonymous" referrerpolicy="no-referrer" />

Photo by [Viktor Hanacek](https://picjumbo.com/author/viktorhanacek/) from [picjumbo.com](picjumbo.com)

## Creating and updating Grafana dashboards

```bash
yay -Syu --needed --noconfirm go-jsonnet jsonnet-bundler
cd ./grafana/src/dashboards
go install
./build-dashboards.sh
```
