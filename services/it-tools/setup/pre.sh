#!/bin/bash
set -eu

# shellcheck source=../../../scripts/helpers.sh
source "./scripts/helpers.sh"

./scripts/register_hostname.sh "it-tools.services.local"

exit 0
