# Docker dashboard

![Preview 1](./assets/preview.png)

Background from [wallpapercave.com](https://wallpapercave.com/)

## Table of Contents

- [About this project](#about-this-project)
- [Installation](#installation)
- [List of available services](#list-of-available-services)
- [Import Bitwarden secrets](#import-bitwarden-secrets)
- [Development](#development)

## About this project

A self-hosted Docker Compose stack for local development with databases, monitoring, automation tools, and utilities. All services run locally with SSO authentication and comprehensive observability.

**What's included:**

- Databases with web interfaces (MySQL, PostgreSQL, MongoDB, Redis)
- Full observability stack with Grafana, Loki, and Alloy for logs, metrics, and visualization
- Prometheus monitoring with comprehensive metrics collection
- Authentik for SSO authentication
- Development tools and utilities
- Workflow automation (n8n) and AI models (Ollama)

No tracking, no external dependencies—just a local development environment you control.

## Installation

Before running the installer make sure [uv](https://docs.astral.sh/uv/), [mkcert](https://github.com/FiloSottile/mkcert?tab=readme-ov-file#linux) and Docker are installed.

> Note: The following services require manual registration / authentication because they have payed OIDC authentication or will have in the future:
>
> - Grafana
> - Mealie
> - n8n
> - pgAdmin4
> - RabbitMQ
>
> The rest of the services are protected by Authentik.

```bash
# Deploy all enabled services
uv run dashboard.py deploy

# Update .env and restart services
uv run dashboard.py update

# Stop and remove all containers, volumes, and networks
uv run dashboard.py reset
```

## List of available services

- [authentik](https://authentik.services.local): authentik is an IdP (Identity Provider) and SSO (Single Sign On) platform that is built with security at the forefront of every piece of code, every feature, with an emphasis on flexibility and versatility
  - [Docker Hub](https://github.com/goauthentik/authentik/pkgs/container/server)
  - [Dockerfile](https://github.com/goauthentik/authentik/blob/main/lifecycle/container/Dockerfile)

- [cAdvisor](https://cadvisor.services.local): Analyzes resource usage and performance characteristics of running containers
  - [Docker Hub](https://github.com/google/cadvisor/pkgs/container/cadvisor)
  - [Dockerfile](https://github.com/google/cadvisor/blob/master/deploy/Dockerfile)

- [Dozzle](https://dozzle.services.local): Real-time Docker log viewer with a web UI
  - [Docker Hub](https://hub.docker.com/r/amir20/dozzle)
  - [Dockerfile](https://github.com/amir20/dozzle/blob/master/Dockerfile)

- [Grafana](https://grafana.services.local): The open and composable observability and data visualization platform
  - [Docker Hub](https://hub.docker.com/r/grafana/grafana)
  - [Dockerfile](https://github.com/grafana/grafana/blob/main/Dockerfile)
  - Additional services:
    - [Grafana Alloy](https://grafana-alloy.services.local): Grafana Alloy is an open source OpenTelemetry collector with built-in Prometheus pipelines and support for metrics, logs, traces, and profiles
      - [Docker Hub](https://hub.docker.com/r/grafana/alloy)
      - [Dockerfile](https://github.com/grafana/alloy/blob/main/Dockerfile)
    - [Loki](null): Loki is a horizontally scalable, highly available, multi-tenant log aggregation system inspired by Prometheus
      - [Docker Hub](https://hub.docker.com/r/grafana/loki)
      - [Dockerfile](https://github.com/grafana/loki/blob/main/cmd/loki/Dockerfile)

- [homepage](https://homepage.services.local): A highly customizable homepage (or startpage / application dashboard) with Docker and service API integrations
  - [Docker Hub](https://hub.docker.com/r/gethomepage/homepage)
  - [Dockerfile](https://github.com/gethomepage/homepage/blob/dev/Dockerfile)

- [IT - TOOLS](https://it-tools.services.local): Collection of handy online tools for developers, with great UX
  - [Docker Hub](https://hub.docker.com/r/corentinth/it-tools)
  - [Dockerfile](https://github.com/CorentinTh/it-tools/blob/main/Dockerfile)

- [Mailpit](https://mailpit.services.local): An email and SMTP testing tool with API for developers
  - [Docker Hub](https://hub.docker.com/r/axllent/mailpit)
  - [Dockerfile](https://github.com/axllent/mailpit/blob/master/Dockerfile)

- [MongoDB](null): MongoDB is a document database with the scalability and flexibility that you want with the querying and indexing that you need
  - [Docker Hub](https://hub.docker.com/_/mongo)
  - [Dockerfile](https://github.com/docker-library/mongo/blob/master/8.0/Dockerfile)
  - Additional services:
    - [mongo-express](https://mongo-express.services.local): Web-based MongoDB admin interface, written with Node.js and Express
      - [Docker Hub](https://hub.docker.com/_/mongo-express)
      - [Dockerfile](https://github.com/mongo-express/mongo-express/blob/master/Dockerfile)
    - [MongoDB exporter](null): A Prometheus exporter for MongoDB including sharding, replication and storage engines
      - [Docker Hub](https://hub.docker.com/r/percona/mongodb_exporter)
      - [Dockerfile](https://github.com/percona/mongodb_exporter/blob/main/Dockerfile)

- [MySQL](null): MySQL is the world's most popular open source database
  - [Docker Hub](https://hub.docker.com/_/mysql)
  - [Dockerfile](https://github.com/docker-library/mysql/blob/master/innovation/Dockerfile.oracle)
  - Additional services:
    - [MySQL Server Exporter](null): A Exporter for MySQL server metrics
      - [Docker Hub](https://hub.docker.com/r/prom/mysqld-exporter)
      - [Dockerfile](https://github.com/prometheus/mysqld_exporter/blob/main/Dockerfile)
    - [phpMyAdmin](https://phpmyadmin.services.local): A web interface for MySQL and MariaDB
      - [Docker Hub](https://hub.docker.com/_/phpmyadmin)
      - [Dockerfile](https://github.com/phpmyadmin/docker/blob/master/apache/Dockerfile)

- [n8n](https://n8n.services.local): n8n is a workflow automation platform that gives technical teams the flexibility of code with the speed of no-code
  - [Docker Hub](https://hub.docker.com/r/n8nio/n8n)
  - [Dockerfile](https://github.com/n8n-io/n8n/blob/master/docker/images/n8n/Dockerfile)

- [ntfy](https://ntfy.services.local): ntfy (pronounced notify) is a simple HTTP-based pub-sub notification service. It allows you to send notifications to your phone or desktop via scripts from any computer, and/or using a REST API
  - [Docker Hub](https://hub.docker.com/r/binwiederhier/ntfy)
  - [Dockerfile](https://github.com/binwiederhier/ntfy/blob/main/Dockerfile)

- [Ollama](null): Chat & build with open models
  - [Docker Hub](https://hub.docker.com/r/ollama/ollama)
  - [Dockerfile](https://github.com/ollama/ollama/blob/main/Dockerfile)
  - Additional services:
    - [Open WebUI](https://open-webui.services.local): Open WebUI is an extensible, self-hosted AI interface that adapts to your workflow, all while operating entirely offline
      - [Docker Hub](https://github.com/open-webui/open-webui/pkgs/container/open-webui)
      - [Dockerfile](https://github.com/open-webui/open-webui/blob/main/Dockerfile)

- [Omni Tools](https://omni-tools.services.local): Self-hosted collection of powerful web-based tools for everyday tasks. No ads, no tracking, just fast, accessible utilities right from your browser!
  - [Docker Hub](https://hub.docker.com/r/iib0011/omni-tools)
  - [Dockerfile](https://github.com/iib0011/omni-tools/blob/main/Dockerfile)

- [PostgreSQL](null): PostgreSQL is a powerful, open source object-relational database system with over 35 years of active development that has earned it a strong reputation for reliability, feature robustness, and performance
  - [Docker Hub](https://hub.docker.com/_/postgres)
  - [Dockerfile](https://github.com/docker-library/postgres/blob/master/17/bookworm/Dockerfile)
  - Additional services:
    - [pgadmin4](https://pgadmin4.services.local): pgAdmin is the most popular and feature rich Open Source administration and development platform for PostgreSQL, the most advanced Open Source database in the world
      - [Docker Hub](https://hub.docker.com/r/dpage/pgadmin4)
      - [Dockerfile](https://github.com/pgadmin-org/pgadmin4/blob/master/Dockerfile)
    - [PostgreSQL Server Exporter](null): A PostgreSQL metric exporter for Prometheus
      - [Docker Hub](https://hub.docker.com/r/prometheuscommunity/postgres-exporter)
      - [Dockerfile](https://github.com/prometheus-community/postgres_exporter/blob/master/Dockerfile)

- [prometheus](https://prometheus.services.local): Monitor your applications, systems, and services with the leading open source monitoring solution. Instrument, collect, store, and query your metrics for alerting, dashboarding, and other use cases
  - [Docker Hub](https://hub.docker.com/r/prom/prometheus)
  - [Dockerfile](https://github.com/prometheus/prometheus/blob/main/Dockerfile)
  - Additional services:
    - [Blackbox Exporter](null): The blackbox exporter allows blackbox probing of endpoints over HTTP, HTTPS, DNS, TCP, ICMP and gRPC
      - [Docker Hub](https://hub.docker.com/r/prom/blackbox-exporter)
      - [Dockerfile](https://github.com/prometheus/blackbox_exporter/blob/master/Dockerfile)
    - [Node Exporter](null): Prometheus exporter for hardware and OS metrics exposed by *NIX kernels, written in Go with pluggable metric collectors
      - [Docker Hub](https://hub.docker.com/r/prom/node-exporter)
      - [Dockerfile](https://github.com/prometheus/node_exporter/blob/master/Dockerfile)

- [RabbitMQ](https://rabbitmq.services.local): RabbitMQ is a reliable and mature messaging and streaming broker, which is easy to deploy on cloud environments, on-premises, and on your local machine. It is currently used by millions worldwide
  - [Docker Hub](https://hub.docker.com/_/rabbitmq)
  - [Dockerfile](https://github.com/docker-library/rabbitmq/blob/master/4.0/alpine/Dockerfile)

- [Redis](null): Redis is the world's fastest in-memory database
  - [Docker Hub](https://hub.docker.com/_/redis)
  - [Dockerfile](https://github.com/redis/docker-library-redis/blob/master/7.4/alpine/Dockerfile)
  - Additional services:
    - [Redis Insight](https://redisinsight.services.local): Redis GUI by Redis
      - [Docker Hub](https://hub.docker.com/r/redis/redisinsight)
      - [Dockerfile](https://github.com/RedisInsight/RedisInsight/blob/main/Dockerfile)

- [SeaweedFS](https://seaweedfs.services.local): Enterprise-Grade Distributed Storage with Self-Healing
  - [Docker Hub](https://hub.docker.com/r/corentinth/it-tools)
  - [Dockerfile](https://github.com/seaweedfs/seaweedfs/blob/master/docker/Dockerfile.local)

- [Traefik](https://traefik.services.local): Traefik is your all-in-one, self-hosted, cloud-native, GitOps-driven application proxy, API gateway, and API management platform
  - [Docker Hub](https://hub.docker.com/_/traefik)
  - [Dockerfile](https://github.com/traefik/traefik/blob/master/Dockerfile)

- [What's up Docker?](https://whatsupdocker.services.local): Keep your containers up-to-date!
  - [Docker Hub](https://hub.docker.com/r/getwud/wud)
  - [Dockerfile](https://github.com/getwud/wud/blob/main/Dockerfile)

## Import Bitwarden secrets

```bash
uv run dashboard.py import-secrets bitwarden@mail.com
```

## Development

```bash
uv sync
npm i
```
