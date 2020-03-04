#!/usr/bin/env bash
set -e

./clone-all.sh

echo ".Sonatype dir"
ls "${SONATYPE_DIR}"
STAGING_REPOSITORY=$(< "${SONATYPE_STAGING_FILE}")
export STAGING_REPOSITORY

RELEASE_VERSION=$(<VERSION)
export RELEASE_VERSION

MAVEN_ARGS="clean install -DskipTests" ./release-all.sh
