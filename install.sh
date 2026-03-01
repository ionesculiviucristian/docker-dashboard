#!/bin/bash
set -eu

source "./scripts/helpers.sh"

is_service_enabled() {
  local service="$1"
  [ "$(yq -r ".\"${service}\" // true" "./services.yml")" = "true" ]
}

if [ "${1:-}" = "--reset" ]; then
  warning_msg "This will remove ALL docker containers, volumes, and networks (images will be kept)"
  read -r -p "Type 'yes' to continue: " confirmation

  if [ "${confirmation}" != "yes" ]; then
    info_msg "Aborted"
    exit 0
  fi

  ./scripts/reset_docker.sh
fi

info_msg "Start installing..."

[ -f "./.env" ] || cp "./.env.example" "./.env"

set -a && source "./.env" && set +a

info_msg "Installing local certificate authority (CA)..."

if ! mkcert -CAROOT >/dev/null; then
  mkcert -install
fi

info_msg "Generating domain certs..."

./scripts/generate_domain_cert.sh "services.local" | indent_msg
./scripts/generate_domain_cert.sh "projects.local" | indent_msg

info_msg "Pre-setup services..."

for pre_script in ./services/*/setup/pre.sh; do
  service_name=$(echo "${pre_script}" | cut -d'/' -f3)
  is_service_enabled "${service_name}" || continue
  info_msg "${service_name}" | indent_msg
  "${pre_script}" | indent_msg 4
done

info_msg "Building compose file list..."

COMPOSE_FILE=""
for dir in ./services/*/; do
  service_name=$(echo "${dir}" | cut -d'/' -f3)
  is_service_enabled "${service_name}" || continue
  compose_file="${dir}docker-compose.yml"
  [ -f "${compose_file}" ] || continue
  COMPOSE_FILE="${COMPOSE_FILE:+${COMPOSE_FILE}:}${compose_file}"
done
export COMPOSE_FILE

info_msg "Starting services..."

if ! output=$(docker compose up -d 2>&1); then
  error_msg "${output}"
  exit 1
fi

info_msg "Post-setup services..."

for post_script in ./services/*/setup/post.sh; do
  service_name=$(echo "${post_script}" | cut -d'/' -f3)
  is_service_enabled "${service_name}" || continue
  info_msg "${service_name}" | indent_msg
  "${post_script}" | indent_msg 4
done

success_msg "Finished installing"

exit 0
