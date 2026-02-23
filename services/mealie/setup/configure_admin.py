#!/usr/bin/env python3
import sys
import sqlite3
import bcrypt

if len(sys.argv) != 5:
    print("Usage: configure_admin.py <default_email> <new_username> <new_email> <new_password>", file=sys.stderr)
    sys.exit(1)

default_email = sys.argv[1]
new_username = sys.argv[2]
new_email = sys.argv[3]
new_password = sys.argv[4]

try:
    conn = sqlite3.connect('/app/data/mealie.db')
    cursor = conn.cursor()
    cursor.execute('SELECT COUNT(*) FROM users WHERE email = ?', (default_email,))
    count = cursor.fetchone()[0]
    conn.close()

    if count == 0:
        print("not_found")
        sys.exit(0)

    hashed = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt(rounds=12))

    conn = sqlite3.connect('/app/data/mealie.db')
    cursor = conn.cursor()
    cursor.execute(
        'UPDATE users SET username = ?, email = ?, full_name = ?, password = ? WHERE email = ?',
        (new_username, new_email, new_username, hashed.decode(), default_email)
    )
    conn.commit()
    conn.close()

    print("success")
    sys.exit(0)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
