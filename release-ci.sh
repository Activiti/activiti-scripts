#!/usr/bin/env bash
set -e

./clone-all.sh

STAGING_REPOSITORY=$(< "${NEXUS_STAGING_FILE}")
export STAGING_REPOSITORY

RELEASE_VERSION=$(<VERSION)
export RELEASE_VERSION

MAVEN_ARGS="clean install -DskipTests -q " ./release-all.sh
