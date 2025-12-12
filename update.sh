#!/bin/bash

set -eu 

docker compose up -d

docker system prune -f

exit 0
