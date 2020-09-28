#!/usr/bin/env bash
set -e

RELEASE_VERSION=$(<VERSION)
export RELEASE_VERSION

read -p "Delete tag ${RELEASE_VERSION} from remote? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
#  git push origin :"${RELEASE_VERSION}" || true

  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  export SCRIPT_DIR

  SCRIPT="${SCRIPT_DIR}/delete-tag.sh" "${SCRIPT_DIR}"/run.sh
fi
