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

This project is a comprehensive Docker-based developer dashboard designed to streamline and enhance your development workflow. It bundles a curated set of essential services and tools—ranging from container monitoring and database management to email testing and customizable start pages—all orchestrated with Docker Compose for easy setup and maintenance.

Whether you want to keep tabs on your running containers with cAdvisor, manage databases using pgAdmin or phpMyAdmin, explore APIs via the homepage dashboard, or test email workflows with Mailpit, this project brings them together in a unified, self-hosted environment.

Built with flexibility and productivity in mind, it helps developers quickly spin up a local ecosystem that covers common development needs without clutter or tracking—just fast, accessible tools running right on your machine.

## Installation

Before running the install script make sure [mkcert](https://github.com/FiloSottile/mkcert?tab=readme-ov-file#linux) is installed.

⚠️ Note: The following services require manual registration / authentication because they have payed OIDC authentication or will have in the future:

- Mealie
- MinIO
- pgAdmin4
- RabbitMQ

The rest of the services are protected by Authentik.

```bash
./install.sh
```

## List of available services

- [authentik](https://authentik.services.local): authentik is an IdP (Identity Provider) and SSO (Single Sign On) platform that is built with security at the forefront of every piece of code, every feature, with an emphasis on flexibility and versatility
  - [Docker Hub](https://hub.docker.com/r/authentik/server)
  - [Dockerfile](https://github.com/goauthentik/authentik/blob/main/lifecycle/container/Dockerfile)
- [cAdvisor](https://cadvisor.services.local): Analyzes resource usage and performance characteristics of running containers
  - [Docker Hub](https://hub.docker.com/r/google/cadvisor)
  - [Dockerfile](https://github.com/google/cadvisor/blob/master/deploy/Dockerfile)
- [homepage](https://homepage.services.local): A highly customizable homepage (or startpage / application dashboard) with Docker and service API integrations
  - [Docker Hub](https://hub.docker.com/r/gethomepage/homepage)
  - [Dockerfile](https://github.com/gethomepage/homepage/blob/dev/Dockerfile)
- [IT - TOOLS](https://it-tools.services.local): Collection of handy online tools for developers, with great UX
  - [Docker Hub](https://hub.docker.com/r/corentinth/it-tools)
  - [Dockerfile](https://github.com/CorentinTh/it-tools/blob/main/Dockerfile)
- [Mailpit](https://mailpit.services.local): An email and SMTP testing tool with API for developers
  - [Docker Hub](https://hub.docker.com/r/axllent/mailpit)
  - [Dockerfile](https://github.com/axllent/mailpit/blob/master/Dockerfile)
- [Mealie](https://mealie.services.local): Mealie is an intuitive and easy to use recipe management app
  - [Docker Hub](https://github.com/mealie-recipes/mealie/pkgs/container/mealie)
  - [Dockerfile](https://github.com/mealie-recipes/mealie/blob/mealie-next/docker/Dockerfile)
- [MinIO](https://minio.services.local): MinIO is a high-performance, S3 compatible object store, open sourced under GNU AGPLv3 license
  - [Docker Hub](https://hub.docker.com/r/minio/minio)
  - [Dockerfile](https://github.com/minio/minio/blob/master/Dockerfile)
- [MongoDB](null): MongoDB is a document database with the scalability and flexibility that you want with the querying and indexing that you need
  - [Docker Hub](https://hub.docker.com/_/mongo)
  - [Dockerfile](https://github.com/docker-library/mongo/blob/master/8.0/Dockerfile)
- [MySQL](null): MySQL is the world's most popular open source database
  - [Docker Hub](https://hub.docker.com/_/mysql)
  - [Dockerfile](https://github.com/docker-library/mysql/blob/master/innovation/Dockerfile.oracle)
- [Ollama](null): Chat & build with open models
  - [Docker Hub](https://hub.docker.com/r/ollama/ollama)
  - [Dockerfile](https://github.com/ollama/ollama/blob/main/Dockerfile)
- [Omni Tools](https://omni-tools.services.local): Self-hosted collection of powerful web-based tools for everyday tasks. No ads, no tracking, just fast, accessible utilities right from your browser!
  - [Docker Hub](https://hub.docker.com/r/iib0011/omni-tools)
  - [Dockerfile](https://github.com/iib0011/omni-tools/blob/main/Dockerfile)
- [PostgreSQL](null): PostgreSQL is a powerful, open source object-relational database system with over 35 years of active development that has earned it a strong reputation for reliability, feature robustness, and performance
  - [Docker Hub](https://hub.docker.com/_/postgres)
  - [Dockerfile](https://github.com/docker-library/postgres/blob/master/17/bookworm/Dockerfile)
- [prometheus](https://prometheus.services.local): Monitor your applications, systems, and services with the leading open source monitoring solution. Instrument, collect, store, and query your metrics for alerting, dashboarding, and other use cases
  - [Docker Hub](https://hub.docker.com/r/prom/prometheus)
  - [Dockerfile](https://github.com/prometheus/prometheus/blob/main/Dockerfile)
- [RabbitMQ](https://rabbitmq.services.local): RabbitMQ is a reliable and mature messaging and streaming broker, which is easy to deploy on cloud environments, on-premises, and on your local machine. It is currently used by millions worldwide
  - [Docker Hub](https://hub.docker.com/_/rabbitmq)
  - [Dockerfile](https://github.com/docker-library/rabbitmq/blob/master/4.0/alpine/Dockerfile)
- [Redis](null): Redis is the world's fastest in-memory database
  - [Docker Hub](https://hub.docker.com/_/redis)
  - [Dockerfile](https://github.com/redis/docker-library-redis/blob/master/7.4/alpine/Dockerfile)
- [Traefik](https://traefik.services.local): Traefik is your all-in-one, self-hosted, cloud-native, GitOps-driven application proxy, API gateway, and API management platform
  - [Docker Hub](https://hub.docker.com/_/traefik)
  - [Dockerfile](https://github.com/traefik/traefik/blob/master/Dockerfile)
- [What's up Docker?](https://whatsupdocker.services.local): Keep your containers up-to-date!
  - [Docker Hub](https://hub.docker.com/r/getwud/wud)
  - [Dockerfile](https://github.com/getwud/wud/blob/main/Dockerfile)

## Import Bitwarden secrets

```bash
./scripts/secrets.sh bitwarden@mail.com
```

## Development

```bash
npm i
```
