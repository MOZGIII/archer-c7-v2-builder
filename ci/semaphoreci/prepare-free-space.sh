#!/bin/bash
set -euo pipefail
# This script takes care of clearing out unneeded stuff
# from the system to get us some space on Semaphore CI.
# It is safe to run in CI because it looks like a new
# fresh VM is created from every build from some
# snapshot, and the disposed after the build is
# finished.

# Do not run it outside of the Semaphore CI because it
# will probably break your system.

if [[ "${SEMAPHORE:-}" != "true" ]]; then
  echo >&2 "Not in Semaphore CI"
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
  rethinkdb \
  elasticsearch \
  '^mongodb-org.*' \
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
