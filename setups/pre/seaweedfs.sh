#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source ".env" && set +a

# shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

s3_config="./services/seaweedfs/s3.json"

cat >"${s3_config}" <<EOF
{
  "identities": [
    {
      "name": "admin",
      "credentials": [
        {
          "accessKey": "${SEAWEEDFS_S3_ACCESS_KEY}",
          "secretKey": "${SEAWEEDFS_S3_SECRET_KEY}"
        }
      ],
      "actions": ["Admin", "Read", "Write", "List", "Tagging"]
    }
  ]
}
EOF

debug_msg "Created S3 config"

exit 0
