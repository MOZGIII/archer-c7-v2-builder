#!/bin/bash
set -euo pipefail

pwd

set -x
git init .
git checkout -b "$BUILD_CFG_BRANCH"
git add -A
git config user.email "$BUILD_CFG_GIT_EMAIL"
git config user.name "$BUILD_CFG_GIT_NAME"
git commit -m "$BUILD_CFG_COMMIT_MSG"
