#!/usr/bin/env bash
set -e

. "$(dirname "$0")/shared-lib.sh"

./clone-all.sh

initializeReleaseVariables

SCRIPT="${SCRIPT_DIR}/prepare-release.sh" "${SCRIPT_DIR}"/run.sh
