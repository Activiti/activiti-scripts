#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "$0" )" && pwd)"

export PROJECTS=activiti-cloud-application
./clone-all.sh

RELEASE_VERSION=$(<VERSION)
export RELEASE_VERSION

./release-all.sh #switch to the right tag
SRC_DIR=${SRC_DIR:-$HOME/src}
echo "SCRIPT_DIR ${SRC_DIR}"
cd ${SRC_DIR}/${PROJECTS} || exit 1
export DOCKER_IMAGES="example-runtime-bundle,activiti-cloud-query,example-cloud-connector,activiti-cloud-modeling"

for DOCKER_IMAGE in ${DOCKER_IMAGES//,/ }
do
  cd ${DOCKER_IMAGE} || exit 1
  ${SCRIPT_DIR}/dockerpush.sh
echo $(basename $(pwd))
  cd .. || exit 1
done

