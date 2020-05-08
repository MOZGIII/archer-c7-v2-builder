#!/bin/bash
set -euo pipefail

cat <<CFG
CONFIG_TARGET_ath79=y
CONFIG_TARGET_ath79_generic=y
CONFIG_TARGET_ath79_generic_DEVICE_tplink_archer-c7-v2=y
CONFIG_DEVEL=y
CONFIG_PACKAGE_libustream-mbedtls=y
CONFIG_DOWNLOAD_FOLDER="${DOWNLOAD_FOLDER:-}"
CONFIG_BINARY_FOLDER="${BINARY_FOLDER:-}"
CONFIG_TESTING_KERNEL=y
CFG

if [[ "${BUILD_CFG_BUILD_ALL_PACKAGES:-}" == "true" ]]; then
  echo "CONFIG_ALL=y"
else
  echo "CONFIG_ALL_KMODS=y"
  echo "CONFIG_ALL_NONSHARED=y"
fi

[[ "${BUILD_CFG_LOW_SPACE:-"false"}" == "true" ]] &&
  echo "CONFIG_DEVEL_AUTOREMOVE=y"

echo "Config generated!" >&2
