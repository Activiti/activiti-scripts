#!/usr/bin/env bash
set -e

RELEASE_VERSION=$(<VERSION)
export RELEASE_VERSION

read -p "Delete tag ${RELEASE_VERSION} from docker registry? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  export SCRIPT_DIR

  SCRIPT="${SCRIPT_DIR}/delete-docker-image.sh" "${SCRIPT_DIR}"/run.sh
fi
