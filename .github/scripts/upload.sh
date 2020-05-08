#!/bin/bash
set -euo pipefail

BRANCH_PREFIX="autobuild-"

CONTENT_PATH="$1"
shift

# Compute branch name.
BRANCH_NAME="${BRANCH_PREFIX}$(date --iso=date --utc)-gha-${GITHUB_RUN_ID}"

# Prepare the path to the private key file.
GIT_PRIVATE_KEY_PATH="$HOME/ssh-upload_key"
trap 'rm -f "$GIT_PRIVATE_KEY_PATH"' EXIT

# Prepare the private key.
printf "%s" "$GIT_PRIVATE_KEY" >"$GIT_PRIVATE_KEY_PATH"

# Chmod the private key so git doesn't complain.
sudo chmod 0600 "$GIT_PRIVATE_KEY_PATH"

OWNER="$(whoami)"

cd "$CONTENT_PATH"
sudo chown -R "$OWNER:$OWNER" .
git init .
git remote add repo "$GIT_REPO_URL"
git config user.email "automation"
git config user.name "Automation"
git checkout -b "$BRANCH_NAME"
git add -A
git commit -m "Automatic build for commit $GITHUB_SHA"

GIT_SSH_COMMAND="ssh -i ${GIT_PRIVATE_KEY_PATH}" git push repo "$BRANCH_NAME"
