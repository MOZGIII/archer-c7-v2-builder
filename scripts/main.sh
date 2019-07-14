#!/bin/bash
set -xeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

BUILDER_PATH="$(pwd)"
BUILD_PATH="/build"
SOURCE_PATH="$BUILD_PATH/source"
DOWNLOAD_FOLDER="$BUILD_PATH/dl"
BINARY_FOLDER="$BUILD_PATH/bin"

# Clone source from our submodules if it's not ready.
if [[ ! -d "$SOURCE_PATH" ]]; then
  git clone "file://$BUILDER_PATH/submodules/source" "$SOURCE_PATH" --depth 1
fi

# Go over to the source dir.
cd "$SOURCE_PATH"

# Once sources are ready, downgrade kernel to 4.14 from 4.19.
sed -i 's/KERNEL_PATCHVER:=4.19/KERNEL_PATCHVER:=4.14/' ./target/linux/ath79/Makefile

# Configure feeds to use our submodules.
sed "s|{root}|file://${BUILDER_PATH}/submodules|" "$BUILDER_PATH/files/feeds.conf.template" > ./feeds.conf

# Update and install feeds.
./scripts/feeds update -a
./scripts/feeds install -a

# Customize build with our configuration.
(
  export DOWNLOAD_FOLDER BINARY_FOLDER
  "$BUILDER_PATH/scripts/mkconfig.sh" > ./.config
)

# Expand configuration.
make defconfig

# Download package sources and other dependencies.
make download "-j$(nproc)"

# Prepare a non-root user to run as.
useradd --home-dir "$BUILD_PATH" --shell /bin/bash nonroot

# Prepare build path for running as non-root.
chown -R nonroot:nonroot "$BUILD_PATH"

# Prepare make invocation.
MAKE_INVOCATION=( "make" )

# When debugging build process use special options for better readability.
if [[ "${BUILD_CFG_BUILD_DEBUGGING:-}" == "true" ]]; then
  MAKE_INVOCATION+=( "-j1" "V=s" )
else
  MAKE_INVOCATION+=( "-j$(nproc)" )
fi

# Ignore errors if we're asked to.
if [[ -n "${BUILD_CFG_IGNORE_ERRORS:-}" ]]; then
  MAKE_INVOCATION+=( "IGNORE_ERRORS=$BUILD_CFG_IGNORE_ERRORS" )
fi

# Invoke make.
su-exec nonroot "${MAKE_INVOCATION[@]}"
