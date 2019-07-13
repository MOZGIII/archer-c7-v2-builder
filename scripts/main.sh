#!/bin/bash
set -xeuo pipefail
NAME="$1"; shift
cd "$(dirname "${BASH_SOURCE[0]}")/.."
BUILDER_PATH="$(pwd)"
BUILD_PATH="/build"
SOURCE_PATH="$BUILD_PATH/source"

pushd "$BUILD_PATH"

[[ ! -d "$SOURCE_PATH" ]] && clone-source "file://$BUILDER_PATH/submodules/source" --depth 1

pushd "$SOURCE_PATH"

sed "s|{root}|file://${BUILDER_PATH}/submodules|" "$BUILDER_PATH/files/feeds.conf.template" > "$SOURCE_PATH/feeds.conf"

# Downgrade kernel to 4.14 from 4.19.
sed -i 's/KERNEL_PATCHVER:=4.19/KERNEL_PATCHVER:=4.14/' ./target/linux/ath79/Makefile

./scripts/feeds update -a
./scripts/feeds install -a

"$BUILDER_PATH/scripts/mkconfig.sh" > "$SOURCE_PATH/.config"

make defconfig
make download

useradd --home-dir "$BUILD_PATH" --shell /bin/bash nonroot

chown -R nonroot:nonroot "$BUILD_PATH"

case "$NAME" in
  "build")
    COMMAND=("make" "-j$(nproc)" "IGNORE_ERRORS=m")
    ;;
  "debug-build")
    COMMAND=("make" "-j1" "V=s")
    ;;
  *)
    echo >&2 "Error: unknown command"
    exit 2
    ;;
esac

su-exec nonroot "${COMMAND[@]}"
