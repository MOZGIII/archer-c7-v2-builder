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

# Measure initally available space.
df -h

# Remove packages to save up some space.
sudo DEBIAN_FRONTEND=noninteractive apt-get -y purge \
  build-essential \
  '^postgresql-.*' \
  rabbitmq-server \
  '^mysql-.*' \
  '^apache2.*' \
  '^php.*' \
  firefox \
  google-chrome-stable \
  ansible \
  '^gradle.*' \
  '^erlang.*' \
  '^redis.*' \
  memcached \
  yarn \
  cassandra \
  '^oracle-.*' \
  '^openj.*' \
  '^java.*' \
  sbt

sudo DEBIAN_FRONTEND=noninteractive apt-get -y autoremove

# Remove /opt.
sudo rm -rf /opt/*

# Clean up home dir.
sudo rm -rf \
  ~/.rbenv \
  ~/.phpbrew \
  ~/.gem \
  ~/.sbt \
  ~/.kern \
  ~/.kiex \
  ~/.pyenv \
  ~/.npm \
  ~/.nvm \
  ~/.lien

# Measure space available for the build.
df -h
