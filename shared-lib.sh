#!/bin/sh

set -e

checkNoSnapshots() {
   grep -r SNAPSHOT --include=pom.xml . && echo "A SNAPSHOT version was found in the POM file: stopping the release..." && exit 1
   echo no SNAPSHOTs found, continuing...
}


initializeS3Variables(){
  S3_M2_REPOSITORY_RELEASE_DIR="${S3_M2_REPOSITORY_DIR}/${RELEASE_VERSION}"
  S3_CLIENT_OPTS="--quiet --exclude * --include *activiti*${RELEASE_VERSION}* --expires $(date -d '+10 days' --utc +'%Y-%m-%dT%H:%M:%SZ')"
}

downloadFromS3(){
  echo "Downloading cache from S3: aws s3 sync ${S3_M2_REPOSITORY_RELEASE_DIR} ${M2_REPOSITORY_DIR} ${S3_CLIENT_OPTS}"
  time aws s3 sync ${S3_M2_REPOSITORY_RELEASE_DIR} ${M2_REPOSITORY_DIR} ${S3_CLIENT_OPTS}
}

initializeReleaseVariables(){
  STAGING_REPOSITORY=$(< "${NEXUS_STAGING_FILE}")
  export STAGING_REPOSITORY

  RELEASE_VERSION=$(<VERSION)
  export RELEASE_VERSION

  SCRIPT_DIR="$(cd "$( dirname "$0" )" && pwd)"
  export SCRIPT_DIR
}
