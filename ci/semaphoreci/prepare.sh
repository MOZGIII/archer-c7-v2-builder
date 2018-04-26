#!/bin/bash
set -euo pipefail

if [[ "${SEMAPHORE:-}" != "true" ]]; then
  echo >&2 "Not in Semaphore CI"
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git submodule update --init
docker pull mozgiii/openwrt-image-builder

"$DIR/prepare-free-space.sh"
