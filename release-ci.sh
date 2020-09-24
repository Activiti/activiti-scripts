#!/usr/bin/env bash
set -e

. "$(dirname "$0")/shared-lib.sh"

./clone-all.sh

initializeReleaseVariables
if [[ -n ${USE_CACHE} ]]; then
  initializeS3Variables
  downloadFromS3
fi

MAVEN_ARGS="clean install -DskipTests -q " ./release-all.sh
