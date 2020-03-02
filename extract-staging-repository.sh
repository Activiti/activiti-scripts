#!/usr/bin/env bash
set -e

STAGING_REPOSITORY=$(grep <"${SONATYPE_STAGING_FILE}" stagedRepositoryId | grep -o "orgactiviti-[0-9]*")
echo "Stating repository ${STAGING_REPOSITORY}"
export STAGING_REPOSITORY
