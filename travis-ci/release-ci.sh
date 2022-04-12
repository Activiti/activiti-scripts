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

if [[ -n ${USE_CACHE} ]]; then
  echo "Uploading cache to S3: aws s3 sync ${M2_REPOSITORY_DIR} ${S3_M2_REPOSITORY_RELEASE_DIR}" --quiet --exclude "*" \
  --include "org/activiti/*${RELEASE_VERSION}*" --exclude "*javadoc.jar*" --exclude "*sources.jar*"\
  --expires $(date -d '+10 days' --utc +'%Y-%m-%dT%H:%M:%SZ')

  time aws s3 sync ${M2_REPOSITORY_DIR} ${S3_M2_REPOSITORY_RELEASE_DIR} --quiet --exclude "*" \
  --include "org/activiti/*${RELEASE_VERSION}*" --exclude "*javadoc.jar*" --exclude "*sources.jar*"\
  --expires $(date -d '+10 days' --utc +'%Y-%m-%dT%H:%M:%SZ')
fi
