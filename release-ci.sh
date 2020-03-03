#!/usr/bin/env bash
set -e

./fetch-versions.sh ${FETCH_AGGREGATOR} "${FETCH_AGGREGATOR_VERSION}"
./clone-all.sh

STAGING_REPOSITORY=$(< "${SONATYPE_STAGING_FILE}")
export STAGING_REPOSITORY

RELEASE_VERSION=$(<VERSION)
export RELEASE_VERSION

MAVEN_ARGS="clean install -DskipTests" ./release-all.sh
