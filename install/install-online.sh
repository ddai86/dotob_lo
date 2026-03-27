#!/usr/bin/env bash
set -euo pipefail
DATA_DIR="/opt/dotob-lo"
COMPOSE_SRC="$(cd "$(dirname "$0")" && pwd)/compose.dotob-lo.prod.online.yaml"
PROJECT_NAME="dotob-lo"
APP_KEY="${APP_KEY:-}"
URL="${URL:-}"
DB_PASSWORD="${DB_PASSWORD:-}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --data-dir) DATA_DIR="$2"; shift 2;;
    --compose) COMPOSE_SRC="$2"; shift 2;;
    --project-name) PROJECT_NAME="$2"; shift 2;;
    --url) URL="$2"; shift 2;;
    --app-key) APP_KEY="$2"; shift 2;;
    --db-password) DB_PASSWORD="$2"; shift 2;;
    --mysql-root-password) MYSQL_ROOT_PASSWORD="$2"; shift 2;;
    *) shift;;
  esac
done
if [[ -z "${APP_KEY}" ]]; then
  if command -v openssl >/dev/null 2>&1; then
    APP_KEY="$(openssl rand -hex 16)"
  else
    APP_KEY="$(tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' </dev/urandom | head -c 24)"
  fi
fi
if [[ -z "${URL}" ]]; then
  URL="http://localhost:8080"
fi
if [[ -z "${DB_PASSWORD}" ]]; then
  DB_PASSWORD="change-me-db"
fi
if [[ -z "${MYSQL_ROOT_PASSWORD}" ]]; then
  MYSQL_ROOT_PASSWORD="change-me-root"
fi
mkdir -p "${DATA_DIR}/storage" "${DATA_DIR}/mysql" "${DATA_DIR}/redis"
cp "${COMPOSE_SRC}" "${DATA_DIR}/compose.yml"
ESCAPED_URL="$(printf '%s\n' "$URL" | sed -e 's/[\/&]/\\&/g')"
sed -i \
  -e "s/URL=http:\/\/SERVER_IP_OR_DOMAIN:8080/URL=${ESCAPED_URL}/g" \
  -e "s/APP_KEY=REPLACE_ME_>=16CHARS/APP_KEY=${APP_KEY}/g" \
  -e "s/DB_PASSWORD=REPLACE_ME/DB_PASSWORD=${DB_PASSWORD}/g" \
  -e "s/MYSQL_ROOT_PASSWORD=REPLACE_ME/MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}/g" \
  "${DATA_DIR}/compose.yml"
docker compose -p "${PROJECT_NAME}" -f "${DATA_DIR}/compose.yml" up -d
echo "OK"
