#!/bin/bash
set -euo pipefail

if [[ "${SEMAPHORE:-}" != "true" ]]; then
  echo >&2 "Not in Semaphore CI"
  exit 1
fi

export BUILD_CFG_LOW_SPACE=true
bin/build
