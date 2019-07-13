#!/bin/bash
set -euo pipefail

BRANCH_PREFIX="autobuild-"

CONTENT_PATH="$1"; shift

# Compute branch name.
BRANCH_NAME="${BRANCH_PREFIX}$(date --iso=minute --utc)"

cd "$CONTENT_PATH"
git init .
git remote add repo "$GIT_REPO_URL"
git checkout -b "$BRANCH_NAME"
git add -A
git commit -m "Automatic build"

GIT_SSH_COMMAND="ssh -i ${GIT_PRIVATE_KEY_PATH}" git push repo "$BRANCH_NAME"