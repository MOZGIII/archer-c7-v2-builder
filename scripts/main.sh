#!/bin/bash
set -xeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
BUILDER_PATH="$(pwd)"
BUILD_PATH="/build"
SOURCE_PATH="$BUILD_PATH/source"

pushd "$BUILD_PATH"

[[ ! -d "$SOURCE_PATH" ]] && clone-source "file://$BUILDER_PATH/submodules/source" --depth 1

pushd "$SOURCE_PATH"

sed "s|{root}|file://${BUILDER_PATH}/submodules|" "$BUILDER_PATH/files/feeds.conf.template" > "$SOURCE_PATH/feeds.conf"

./scripts/feeds update -a
./scripts/feeds install -a

cp "$BUILDER_PATH/files/config.seed" "$SOURCE_PATH/.config"

make defconfig
make download

useradd --home-dir "$BUILD_PATH" --shell /bin/bash nonroot

chown -R nonroot:nonroot "$BUILD_PATH"

su nonroot --preserve-environment -c "make -j$(nproc)"
