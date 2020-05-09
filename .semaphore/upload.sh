#!/bin/bash
set -euo pipefail

BRANCH_PREFIX="autobuild-"

CONTENT_PATH="$1"; shift

# Compute branch name.
BRANCH_NAME="${BRANCH_PREFIX}$(date --iso=date --utc)-sem-${SEMAPHORE_JOB_ID}"

# Expand private key path before changing directory.
GIT_PRIVATE_KEY_PATH="$(realpath "$GIT_PRIVATE_KEY_PATH")"

# Chmod the private key so git doesn't complain.
sudo chmod 0600 "$GIT_PRIVATE_KEY_PATH"

OWNER="$(whoami)"

cd "$CONTENT_PATH"
sudo chown -R "$OWNER:$OWNER" .
git init .
git remote add repo "$GIT_REPO_URL"
git config user.email "semaphore-ci@localhost"
git config user.name "Semaphore CI"
git checkout -b "$BRANCH_NAME"
git add -A
git commit -m "Automatic build for commit $SEMAPHORE_GIT_SHA"

GIT_SSH_COMMAND="ssh -i ${GIT_PRIVATE_KEY_PATH}" git push repo "$BRANCH_NAME"
