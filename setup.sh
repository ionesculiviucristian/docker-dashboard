#!/bin/bash
set -eu 

cd ~/Projects/services
( set -a; source .env; set +a;
docker network create "$NGINX_PROXY_NETWORK" )


cd ~/Projects/services
./generate-cert.sh cadvisor.localdev
./generate-htpasswd.sh cadvisor.localdev


cd ~/Projects/services
./generate-cert.sh geoserver.localdev


cd ~/Projects/services
./generate-cert.sh grafana.localdev


cd ~/Projects/services
./generate-cert.sh homepage.localdev
./generate-htpasswd.sh homepage.localdev


cd ~/Projects/services
./generate-cert.sh it-tools.localdev
./generate-htpasswd.sh it-tools.localdev

cd ~/Projects/services
./generate-cert.sh mailpit.localdev

cd ~/Projects/services
./generate-cert.sh minio.localdev


cd ~/Projects/services
./generate-cert.sh mongo-express.localdev

cd ~/Projects/services/mongo
openssl rand -base64 756 > keyfile
chmod 400 keyfile
sudo chown 999:999 keyfile


cd ~/Projects/services
./generate-cert.sh phpmyadmin.localdev
./generate-secret.sh MYSQL_ROOT_PASSWORD
USE_DEV_PASSWORD=true ./generate-secret.sh MYSQL_DEV_PASSWORD

cd ~/Projects/services
./generate-cert.sh omni-tools.localdev


cd ~/Projects/services
./generate-cert.sh planka.localdev


cd ~/Projects/services
./generate-cert.sh prometheus.localdev
./generate-htpasswd.sh prometheus.localdev


cd ~/Projects/services
./generate-cert.sh pgadmin4.localdev
./generate-secret.sh POSTGRES_PASSWORD
USE_DEV_PASSWORD=true ./generate-secret.sh POSTGRES_DEV_PASSWORD


cd ~/Projects/services
./generate-cert.sh rabbitmq.localdev


cd ~/Projects/services
./generate-cert.sh redisinsight.localdev
./generate-htpasswd.sh redisinsight.localdev


cd ~/Projects/services
./generate-cert.sh whatsupdocker.localdev
./generate-htpasswd.sh whatsupdocker.localdev


cd ~/Projects/services
./generate-cert.sh adguardhome.localdev


cd ~/Projects/services
./generate-cert.sh bitwarden.localdev


cd ~/Projects/services
./generate-cert.sh gitlab.localdev


cd ~/Projects/services
./generate-cert.sh healthchecks.localdev


cd ~/Projects/services
./generate-cert.sh mirotalk.localdev


cd ~/Projects/services
./generate-cert.sh kimai.localdev


cd ~/Projects/services
./generate-cert.sh linkwarden.localdev


cd ~/Projects/services
./generate-cert.sh owncloud.localdev


cd ~/Projects/services
./generate-cert.sh uptime-kuma.localdev


cd ~/Projects/services
docker compose up -d

docker compose exec mongo mongosh -u developer --eval 'rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "mongo:27017" }] })'

docker compose exec mysql mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT CREATE, ALTER, DROP ON *.* TO 'developer'@'%'; FLUSH PRIVILEGES"

docker compose exec healthchecks /opt/healthchecks/manage.py createsuperuser
