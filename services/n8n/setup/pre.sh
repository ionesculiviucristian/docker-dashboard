#!/bin/bash
set -eu

# shellcheck source=../../../scripts/helpers.sh
source "./scripts/helpers.sh"

./scripts/register_hostname.sh "n8n.services.local"

exit 0
