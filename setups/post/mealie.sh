#!/bin/bash
set -eu

# shellcheck source=../../.env
set -a && source "./.env" && set +a

# shellcheck source="../../scripts/helpers.sh"
source "./scripts/helpers.sh"

info_msg "Configuring Mealie admin account..."

wait_for_service "mealie" "python -m mealie.scripts.healthcheck"

default_email="changeme@example.com"

user_exists=$(docker compose exec -T mealie python3 -c "
import sqlite3
conn = sqlite3.connect('/app/data/mealie.db')
cursor = conn.cursor()
cursor.execute('SELECT COUNT(*) FROM users WHERE email = ?', ('${default_email}',))
count = cursor.fetchone()[0]
conn.close()
print(count)
" 2>/dev/null || echo "0"
)

if [ "$user_exists" -gt 0 ]; then
  info_msg "Updating default admin account..."

  docker compose exec -T mealie python3 <<PYTHON
import bcrypt
import sqlite3

password = '${SERVICES_USER_PASSWORD}'
hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt(rounds=12))

conn = sqlite3.connect('/app/data/mealie.db')
cursor = conn.cursor()
cursor.execute(
    'UPDATE users SET username = ?, email = ?, full_name = ?, password = ? WHERE email = ?',
    ('${SERVICES_USER}', '${SERVICES_USER_EMAIL}', '${SERVICES_USER}', hashed.decode(), '${default_email}')
)
conn.commit()
conn.close()
PYTHON

  info_msg "Mealie admin account updated successfully"
else
  info_msg "Mealie already configured (default user not found)"
fi

exit 0
