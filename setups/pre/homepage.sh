#!/bin/bash
set -eu 

#shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

bookmarks_file="./services/homepage/config/bookmarks.yaml"

if [ -f "${bookmarks_file}" ]; then
  debug_msg "Dummy bookmarks file already exists"
else
  touch "${bookmarks_file}"

  debug_msg "Created dummy bookmarks file"
fi

exit 0
