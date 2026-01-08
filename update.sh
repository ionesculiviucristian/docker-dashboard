#!/bin/bash
set -eu

if [ -f .env ]; then
    awk -F= '
        NR==FNR {
            if (/^[A-Z_]/ && $2 != "\"\"")
                e[$1] = substr($0, index($0, "=") + 1)
            next
        }
        /^[A-Z_][A-Z0-9_]*=""$/ && $1 in e {
            print $1 "=" e[$1]
            next
        }
        { print }
    ' .env .env.example > .env.tmp
    mv .env.tmp .env
else
    cp .env.example .env
fi

docker compose up -d

docker system prune -f

exit 0
