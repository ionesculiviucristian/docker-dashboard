#!/bin/bash
set -eu

# shellcheck source=../../../.env
set -a && source "./.env" && set +a

# shellcheck source=../../../scripts/helpers.sh
source "./scripts/helpers.sh"

wait_for_service "ntfy" \
  "wget -q --tries=1 http://127.0.0.1:${NTFY_HOSTNAME_PORT}/v1/health -O /dev/null"

topic="${WHATSUPDOCKER_WUD_TRIGGER_NTFY_LOCAL_TOPIC}"

# Create WUD user (write-only to topic)
if docker compose exec -T ntfy ntfy user list 2>/dev/null | grep -q "${NTFY_WUD_USER}"; then
  warning_msg "ntfy user '${NTFY_WUD_USER}' already exists"
else
  info_msg "Creating ntfy user '${NTFY_WUD_USER}'..."

  docker compose exec -T -e NTFY_PASSWORD="${NTFY_WUD_PASSWORD}" ntfy \
    ntfy user add --ignore-exists "${NTFY_WUD_USER}" >/dev/null 2>&1

  success_msg "ntfy user '${NTFY_WUD_USER}' created"
fi

docker compose exec -T ntfy ntfy access "${NTFY_WUD_USER}" "${topic}" "write-only" >/dev/null 2>&1

# Create subscriber user (read-only to topic)
if docker compose exec -T ntfy ntfy user list 2>/dev/null | grep -q "${NTFY_SUBSCRIBE_USER}"; then
  warning_msg "ntfy user '${NTFY_SUBSCRIBE_USER}' already exists"
else
  info_msg "Creating ntfy user '${NTFY_SUBSCRIBE_USER}'..."

  docker compose exec -T -e NTFY_PASSWORD="${NTFY_SUBSCRIBE_PASSWORD}" ntfy \
    ntfy user add --ignore-exists "${NTFY_SUBSCRIBE_USER}" >/dev/null 2>&1

  success_msg "ntfy user '${NTFY_SUBSCRIBE_USER}' created"
fi

docker compose exec -T ntfy ntfy access "${NTFY_SUBSCRIBE_USER}" "${topic}" "read-only" >/dev/null 2>&1

docker compose up -d --force-recreate whatsupdocker

# Set up systemd subscribe service
service_name="ntfy-subscribe"
service_dir="${HOME}/.config/systemd/user"
service_file="${service_dir}/${service_name}.service"

mkdir -p "${service_dir}"

envsubst '${NTFY_SUBSCRIBE_USER} ${NTFY_SUBSCRIBE_PASSWORD} ${NTFY_HOSTNAME} ${WHATSUPDOCKER_WUD_TRIGGER_NTFY_LOCAL_TOPIC}' \
  <"./services/ntfy/setup/ntfy-subscribe.service" >"${service_file}"

systemctl --user daemon-reload
systemctl --user enable --now "${service_name}"
systemctl --user restart "${service_name}"

success_msg "systemd service '${service_name}' enabled and started"

exit 0
