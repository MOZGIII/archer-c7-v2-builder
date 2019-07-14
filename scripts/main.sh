#!/bin/bash
set -xeuo pipefail
NAME="$1"; shift
cd "$(dirname "${BASH_SOURCE[0]}")/.."
BUILDER_PATH="$(pwd)"
BUILD_PATH="/build"
SOURCE_PATH="$BUILD_PATH/source"
DOWNLOAD_FOLDER="$BUILD_PATH/dl"
BINARY_FOLDER="$BUILD_PATH/bin"

pushd "$BUILD_PATH"

[[ ! -d "$SOURCE_PATH" ]] && clone-source "file://$BUILDER_PATH/submodules/source" --depth 1

pushd "$SOURCE_PATH"

sed "s|{root}|file://${BUILDER_PATH}/submodules|" "$BUILDER_PATH/files/feeds.conf.template" > "$SOURCE_PATH/feeds.conf"

# Downgrade kernel to 4.14 from 4.19.
sed -i 's/KERNEL_PATCHVER:=4.19/KERNEL_PATCHVER:=4.14/' ./target/linux/ath79/Makefile

./scripts/feeds update -a
./scripts/feeds install -a

(
  export DOWNLOAD_FOLDER BINARY_FOLDER
  "$BUILDER_PATH/scripts/mkconfig.sh" > .config
)

make defconfig
make download

useradd --home-dir "$BUILD_PATH" --shell /bin/bash nonroot

chown -R nonroot:nonroot "$BUILD_PATH"

make_args() {
  if [[ -n "${BUILD_CFG_IGNORE_ERRORS:-}" ]]; then
    COMMAND+=( "IGNORE_ERRORS=$BUILD_CFG_IGNORE_ERRORS" )
  fi
}

case "$NAME" in
  "build")
    COMMAND=( "make" "-j$(nproc)" )
    make_args
    ;;
  "debug-build")
    COMMAND=( "make" "-j1" "V=s" )
    make_args
    ;;
  *)
    echo >&2 "Error: unknown command"
    exit 2
    ;;
esac

su-exec nonroot "${COMMAND[@]}"
