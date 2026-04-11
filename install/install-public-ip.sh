#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${DOTOB_HOST_DATA_DIR:-/opt/dotob-lo}"
PUBLIC_HOST=""
PROJECT_NAME="dotob-lo"
COMPOSE_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/compose.dotob-lo.prod.public.ip.yaml"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --data-dir)
      DATA_DIR="$2"; shift 2;;
    --public-host)
      PUBLIC_HOST="$2"; shift 2;;
    --project-name)
      PROJECT_NAME="$2"; shift 2;;
    *)
      echo "Unknown argument: $1"; exit 1;;
  esac
done

generate_hex_32() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 16
    return 0
  fi
  if command -v od >/dev/null 2>&1; then
    od -An -N16 -tx1 /dev/urandom | tr -d ' \n'
    return 0
  fi
  tr -dc 'a-f0-9' </dev/urandom | head -c 32
}

detect_lan_ip() {
  if command -v ip >/dev/null 2>&1; then
    ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="src") {print $(i+1); exit}}'
    return 0
  fi
  if command -v hostname >/dev/null 2>&1; then
    hostname -I 2>/dev/null | awk '{print $1}'
    return 0
  fi
  return 1
}

if [[ -z "$PUBLIC_HOST" ]]; then
  PUBLIC_HOST="$(detect_lan_ip || true)"
fi
if [[ -z "$PUBLIC_HOST" ]]; then
  PUBLIC_HOST="localhost"
fi

APP_KEY="$(generate_hex_32)"
DB_PASSWORD="$(generate_hex_32)"
MYSQL_ROOT_PASSWORD="$(generate_hex_32)"
PUBLIC_URL="http://${PUBLIC_HOST}"

mkdir -p "${DATA_DIR}/storage" "${DATA_DIR}/mysql" "${DATA_DIR}/redis" "${DATA_DIR}/registry"
cp "${COMPOSE_SRC}" "${DATA_DIR}/compose.yml"

ESCAPED_PUBLIC_URL="$(printf '%s\n' "$PUBLIC_URL" | sed -e 's/[\/&]/\\&/g')"
sed -i \
  -e "s|DOTOB_PUBLIC_URL=http://SERVER_IP_OR_DOMAIN|DOTOB_PUBLIC_URL=${ESCAPED_PUBLIC_URL}|g" \
  -e "s|URL=\${DOTOB_PUBLIC_URL:-http://SERVER_IP_OR_DOMAIN}|URL=${ESCAPED_PUBLIC_URL}|g" \
  -e "s|DOTOB_APPS_GATEWAY_URL=\${DOTOB_PUBLIC_URL:-http://SERVER_IP_OR_DOMAIN}|DOTOB_APPS_GATEWAY_URL=${ESCAPED_PUBLIC_URL}|g" \
  -e "s|APP_KEY=\${APP_KEY}|APP_KEY=${APP_KEY}|g" \
  -e "s|DB_PASSWORD=\${DB_PASSWORD}|DB_PASSWORD=${DB_PASSWORD}|g" \
  -e "s|MYSQL_ROOT_PASSWORD=\${MYSQL_ROOT_PASSWORD}|MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}|g" \
  "${DATA_DIR}/compose.yml"

docker compose -p "$PROJECT_NAME" -f "${DATA_DIR}/compose.yml" up -d

echo "OK"
echo "URL: ${PUBLIC_URL}"
echo "DATA_DIR: ${DATA_DIR}"

