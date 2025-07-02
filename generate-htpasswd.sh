#!/bin/bash
set -eu 

if [ -z "$1" ]; then
  echo "Error: No hostname provided. Usage: $0 <hostname>"
  exit 1
fi

HOSTNAME=$1

echo "$(docker run --rm --entrypoint htpasswd httpd:2 -Bbn developer 1q2w3e4r5t6y)" > ./nginx-proxy/htpasswd/${HOSTNAME};
