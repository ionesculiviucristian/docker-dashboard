#!/bin/bash
set -eu

mongosh <<EOL
use admin;
db.createUser({
  "user": "${MONGO_EXPORTER_USER}",
  "pwd": "${MONGO_EXPORTER_USER_PASSWORD}",
  "roles": [
    { "role": "clusterMonitor", "db": "admin" },
    { "role":"read", "db":"local" }
  ]
});
EOL
