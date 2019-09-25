#!/bin/bash
set -xeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

BUILDER_PATH="$BUILD_CFG_BUILDER_PATH"
BUILD_PATH="$BUILD_CFG_BUILD_PATH"
SOURCE_PATH="$BUILD_PATH/source"
DOWNLOAD_FOLDER="$BUILD_PATH/dl"
BINARY_FOLDER="$BUILD_PATH/bin"
STEP_FILE_PATH="$BUILD_PATH/step"

check_exit_point() {
  local CURRENT_POINT="$1" ; shift
  if [[ "${BUILD_CFG_EXIT_AFTER:-}" == "$CURRENT_POINT" ]]; then
    echo "Reached exit point $CURRENT_POINT and exiting as requested..." >&2
    exit 0
  fi
}

read_step() {
  if [[ -f "$STEP_FILE_PATH" ]]; then
    cat "$STEP_FILE_PATH"
  else
    echo "clone"
  fi
}

write_step() {
  local STEP="$1"
  echo "$STEP" > "$STEP_FILE_PATH"
}

before_step() {
  local STEP="$1"

  if [[ "$STEP" == "clone" ]]; then
    # Skip change dir at the clone step.
    return
  fi

  # Go over to the source dir.
  cd "$SOURCE_PATH"
}

execute_step() {
  local STEP="$1"
  case "$STEP" in
    "clone")
      # Clone source from our submodules if it's not ready.
      if [[ ! -d "$SOURCE_PATH" ]]; then
        git clone "file://$BUILDER_PATH/submodules/source" "$SOURCE_PATH" --depth 1
      fi

      # Schedule next execution step.
      write_step "config"
      ;;
    "config")
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

      # Schedule next execution step.
      write_step "download"
      ;;
    "download")
      # Download package sources and other dependencies.
      make download "-j$(nproc)"

      # Schedule next execution step.
      write_step "prebuild"
      ;;
    "prebuild")
      # Prepare a non-root user to run as.
      useradd --home-dir "$BUILD_PATH" --shell /bin/bash nonroot

      # Prepare build path for running as non-root.
      chown -R nonroot:nonroot "$BUILD_PATH"

      # Schedule next execution step.
      write_step "build"
      ;;
    "build")
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

      # Schedule next execution step.
      write_step "done"
      ;;
    "done")
      echo Done
      exit 0
      ;;
  esac
}

main_loop() {
  while true; do
    local STEP
    # Read the pending step.
    STEP="$(read_step)"

    # Log the step.
    echo >&2 "==> $STEP"

    # Invoke common commands before each step.
    before_step "$STEP"

    # Execute the step.
    execute_step "$STEP"

    # Exit here if requested.
    check_exit_point "$STEP"
  done
}

main_loop
