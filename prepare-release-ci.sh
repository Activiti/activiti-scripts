#!/usr/bin/env bash
set -e

. "$(dirname "$0")/shared-lib.sh"

./clone-all.sh

initializeReleaseVariables
if [[ -n ${USE_CACHE} ]]; then
  initializeS3Variables
  downloadFromS3
fi

SCRIPT="${SCRIPT_DIR}/prepare-release.sh" "${SCRIPT_DIR}"/run.sh

if [[ -n ${USE_CACHE} ]]; then
  echo "Uploading cache to S3: aws s3 sync ${M2_REPOSITORY_DIR} ${S3_M2_REPOSITORY_RELEASE_DIR}" --quiet --exclude "*" --include "*${RELEASE_VERSION}*"  --expires $(date -d '+10 days' --utc +'%Y-%m-%dT%H:%M:%SZ')
  time aws s3 sync ${M2_REPOSITORY_DIR} ${S3_M2_REPOSITORY_RELEASE_DIR} --quiet --exclude "*" --include "*${RELEASE_VERSION}*" --expires $(date -d '+10 days' --utc +'%Y-%m-%dT%H:%M:%SZ')
fi
