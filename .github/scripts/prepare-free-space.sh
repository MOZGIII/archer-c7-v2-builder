#!/bin/bash
set -euo pipefail
# This script takes care of clearing out unneeded stuff from the system to get
# us some extra space on Github Actions VM.
# It is safe to run in CI because it looks like a new fresh VM is created from
# every build from a snapshot, and the disposed after the build is finished.

# Do not run it locally because it will probably break your system.

if [[ "${CI:-}" != "true" ]]; then
  echo "Not in CI" >&2
  exit 1
fi

set -x

# Measure initally available space.
df -h

# Remove packages to save up some space.
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y aptitude ubuntu-minimal
sudo aptitude markauto -y '~i!~M!~prequired!~pimportant!~R~prequired!~R~R~prequired!~R~pimportant!~R~R~pimportant!busybox!grub!initramfs-tools'
sudo aptitude hold -y moby-engine moby-cli
sudo aptitude purge -y '~c'
sudo apt-get --purge autoremove
sudo apt-get clean

# Remove /opt and /usr/local.
du -h -d 1 /opt /usr/local
sudo rm -rf /opt/* /usr/local/*

# Remove docker images.
mapfile -t DOCKER_IMAGES < <(docker image ls -q)
docker image rm "${DOCKER_IMAGES[@]}"

# Measure space available for the build.
df -h
