#!/usr/bin/env bash
set -e

. "$(dirname "$0")/shared-lib.sh"

./clone-all.sh

initializeReleaseVariables

MAVEN_ARGS="clean install -DskipTests -q " ./release-all.sh
