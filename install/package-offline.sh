#!/usr/bin/env bash
set -euo pipefail

NO_CACHE=false
INCLUDE_APPS=false
VERSION="1.0"
OUT_DIR="install/dist"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-cache)
      NO_CACHE=true; shift;;
    --include-apps)
      INCLUDE_APPS=true; shift;;
    --version)
      VERSION="$2"; shift 2;;
    --out-dir)
      OUT_DIR="$2"; shift 2;;
    *)
      echo "Unknown argument: $1"; exit 1;;
  esac
done

LOCAL_IMAGE="dotob-lo-admin:${VERSION}"
mkdir -p "$OUT_DIR"

if $NO_CACHE; then
  docker build --no-cache -t "$LOCAL_IMAGE" -f Dockerfile .
else
  docker build -t "$LOCAL_IMAGE" -f Dockerfile .
fi

core_images=(
  "$LOCAL_IMAGE"
  "tecnativa/docker-socket-proxy:v0.4.1"
  "nginx:1.27-alpine"
  "traefik:v3.1"
  "registry:2"
  "mysql:8.0"
  "redis:7-alpine"
  "amir20/dozzle:v10.0"
)

if $INCLUDE_APPS; then
  core_images+=(
    "ghcr.io/kiwix/kiwix-serve:3.8.1"
    "qdrant/qdrant:v1.16"
    "ollama/ollama:0.15.2"
    "ghcr.io/gchq/cyberchef:10.19.4"
    "dullage/flatnotes:v5.5.4"
    "treehouses/kolibri:0.12.8"
  )
fi

for img in "${core_images[@]}"; do
  if [[ "$img" == "$LOCAL_IMAGE" ]]; then
    continue
  fi
  docker pull "$img" >/dev/null
done

tar_path="$OUT_DIR/dotob-lo_offline_${VERSION}.tar"
docker save -o "$tar_path" "${core_images[@]}"

sha_path="$tar_path.sha256"
sha256sum "$tar_path" | awk '{print tolower($1)"  "FILENAME}' FILENAME="$(basename "$tar_path")" > "$sha_path"

echo "Created: $tar_path"
echo "Created: $sha_path"

