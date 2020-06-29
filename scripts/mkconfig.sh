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
CONFIG_TOOLCHAINOPTS=y
CONFIG_GCC_USE_VERSION_9=y
CONFIG_GCC_VERSION_9=y
CONFIG_LUCI_LANG_ALL=n
CFG

if [[ "${BUILD_CFG_BUILD_ALL_PACKAGES:-}" == "true" ]]; then
  echo "CONFIG_ALL=y"
else
  echo "CONFIG_ALL_KMODS=y"
  echo "CONFIG_ALL_NONSHARED=y"
fi

if [[ "${BUILD_CFG_LOW_SPACE:-"false"}" == "true" ]]; then
  echo "CONFIG_AUTOREMOVE=y"
fi

echo "Config generated!" >&2
