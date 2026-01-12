#!/bin/bash
set -eu

# shellcheck source="./helpers.sh"
source "./scripts/helpers.sh"

if [ -f "./.env" ]; then
    gpu_config=""

    if grep -q "^AI_PROFILE=" "./.env"; then
        current_ai_profile=$(grep "^AI_PROFILE=" "./.env" | cut -d= -f2-)
        # shellcheck disable=SC2016
        if echo "${current_ai_profile}" | grep -q '${OLLAMA_NVIDIAGPU}'; then
            gpu_config=':${OLLAMA_NVIDIAGPU}'
        elif echo "${current_ai_profile}" | grep -q '${OLLAMA_AMDGPU}'; then
            gpu_config=':${OLLAMA_AMDGPU}'
        fi
    fi

    awk -v gpu_config="${gpu_config}" -F= '
        NR==FNR {
            if (/^[A-Z_]/ && $2 != "\"\"")
                e[$1] = substr($0, index($0, "=") + 1)
            next
        }
        /^[A-Z_][A-Z0-9_]*=""$/ && $1 in e {
            print $1 "=" e[$1]
            next
        }
        /^AI_PROFILE=/ && gpu_config != "" {
            value = substr($0, index($0, "=") + 1)
            gsub(/"$/, gpu_config "\"", value)
            print $1 "=" value
            next
        }
        { print }
    ' "./.env" "./.env.example" > "./.env.tmp"
    mv "./.env.tmp" "./.env"
else
    cp "./.env.example" "./.env"
fi

exit 0
