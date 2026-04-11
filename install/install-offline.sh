#!/usr/bin/env bash
set -euo pipefail

BUNDLE_TAR="install/dist/dotob-lo_offline_1.0.tar"
DATA_DIR="${DOTOB_HOST_DATA_DIR:-/opt/dotob-lo}"
SERVER_HOST=""
PROJECT_NAME="dotob-lo"
COMPOSE_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/compose.dotob-lo.prod.offline.yaml"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bundle-tar)
      BUNDLE_TAR="$2"; shift 2;;
    --data-dir)
      DATA_DIR="$2"; shift 2;;
    --server-host)
      SERVER_HOST="$2"; shift 2;;
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

if [[ -z "$SERVER_HOST" ]]; then
  SERVER_HOST="$(detect_lan_ip || true)"
fi
if [[ -z "$SERVER_HOST" ]]; then
  SERVER_HOST="localhost"
fi

if [[ ! -f "$BUNDLE_TAR" ]]; then
  echo "Bundle tar not found: $BUNDLE_TAR"; exit 1
fi

docker load -i "$BUNDLE_TAR" >/dev/null

APP_KEY="$(generate_hex_32)"
DB_PASSWORD="$(generate_hex_32)"
MYSQL_ROOT_PASSWORD="$(generate_hex_32)"

URL="http://${SERVER_HOST}:8080"
GATEWAY_URL="http://${SERVER_HOST}:8081"

mkdir -p "${DATA_DIR}/storage" "${DATA_DIR}/mysql" "${DATA_DIR}/redis" "${DATA_DIR}/registry"
cp "${COMPOSE_SRC}" "${DATA_DIR}/compose.yml"

ESCAPED_URL="$(printf '%s\n' "$URL" | sed -e 's/[\/&]/\\&/g')"
ESCAPED_GATEWAY_URL="$(printf '%s\n' "$GATEWAY_URL" | sed -e 's/[\/&]/\\&/g')"

sed -i \
  -e "s/URL=http:\/\/SERVER_IP_OR_DOMAIN:8080/URL=${ESCAPED_URL}/g" \
  -e "s/DOTOB_APPS_GATEWAY_URL=http:\/\/SERVER_IP_OR_DOMAIN:8081/DOTOB_APPS_GATEWAY_URL=${ESCAPED_GATEWAY_URL}/g" \
  -e "s/APP_KEY=REPLACE_ME_>=16CHARS/APP_KEY=${APP_KEY}/g" \
  -e "s/DB_PASSWORD=REPLACE_ME/DB_PASSWORD=${DB_PASSWORD}/g" \
  -e "s/MYSQL_ROOT_PASSWORD=REPLACE_ME/MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}/g" \
  "${DATA_DIR}/compose.yml"

docker compose -p "$PROJECT_NAME" -f "${DATA_DIR}/compose.yml" up -d

echo "OK"
echo "Admin: ${URL}"
echo "Gateway: ${GATEWAY_URL}"
echo "DATA_DIR: ${DATA_DIR}"

