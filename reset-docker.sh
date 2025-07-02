#!/bin/bash
# shellcheck disable=SC2046
set -eu 

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
