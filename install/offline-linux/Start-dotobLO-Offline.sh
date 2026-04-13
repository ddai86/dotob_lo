#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TAR="$DIR/dotob-lo_core_1.0.tar"
INSTALL_SH="$DIR/install-offline.sh"

if [[ ! -f "$TAR" ]]; then
  echo "Missing offline tar: $TAR" >&2
  exit 1
fi

if [[ ! -f "$INSTALL_SH" ]]; then
  echo "Missing installer script: $INSTALL_SH" >&2
  exit 1
fi

exec bash "$INSTALL_SH" --bundle-tar "$TAR"

