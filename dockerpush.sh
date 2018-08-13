#!/usr/bin/env bash
set -ex

echo "BAMBOO_OPTS=${BAMBOO_OPTS}"

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
echo $SCRIPT_DIR
GIT_PROJECT=$(basename $(pwd))
echo $GIT_PROJECT

git remote set-url origin https://${GIT_AUTHOR_NAME}:${GIT_PASSWORD}@github.com/Activiti/$GIT_PROJECT.git

git checkout ${RELEASE_VERSION}

mvn clean install -DskipTests

if [ -n "${DOCKER_PUSH}" ]
then
  docker build -t activiti/${GIT_PROJECT}:${RELEASE_VERSION} .
  docker push docker.io/activiti/${GIT_PROJECT}:${RELEASE_VERSION}
fi
