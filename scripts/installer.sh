#!/bin/bash
set -eu 

docker_reset() {
    # shellcheck disable=SC2046
    docker stop $(docker ps -aq) 
    # shellcheck disable=SC2046
    docker rm -v $(docker ps -aq)
    docker network prune -f
    # shellcheck disable=SC2046
    docker volume rm $(docker volume ls -q)
}

create_docker_network() {
  local name="$1"
  if ! docker network inspect "${name}" >/dev/null; then
    docker network create "${name}"
  fi
}
