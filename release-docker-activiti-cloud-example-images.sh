#!/usr/bin/env bash
set -e

. "$(dirname "$0")/shared-lib.sh"

SCRIPT_DIR="$(cd "$( dirname "$0" )" && pwd)"

export PROJECTS=activiti-cloud-application
./clone-all.sh

RELEASE_VERSION=$(<VERSION)
export RELEASE_VERSION

SRC_DIR=${SRC_DIR:-$HOME/src}
echo "SCRIPT_DIR ${SRC_DIR}"
cd ${SRC_DIR}/${PROJECTS} || exit 1

git fetch --tags
git checkout "${RELEASE_VERSION}"

export DOCKER_IMAGES="example-runtime-bundle,activiti-cloud-query,example-cloud-connector,activiti-cloud-modeling"

initializeS3Variables
downloadFromS3

for DOCKER_IMAGE in ${DOCKER_IMAGES//,/ }
do
  cd ${DOCKER_IMAGE} || exit 1
  ${SCRIPT_DIR}/dockerpush.sh
  cd .. || exit 1
done
