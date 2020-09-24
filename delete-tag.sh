#!/usr/bin/env bash
set -e

GIT_PROJECT=$(basename $(pwd))
echo "Deleting tag ${RELEASE_VERSION} for $GIT_PROJECT from $(pwd)"
echo "SCRIPT_DIR IS $SCRIPT_DIR"
git push origin :"${RELEASE_VERSION}" || true
