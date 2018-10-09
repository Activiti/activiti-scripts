#!/usr/bin/env bash
set -ex

echo "BAMBOO_OPTS=${BAMBOO_OPTS}"

GIT_PROJECT=$(basename $(pwd))

echo "BUILDING IMAGE FOR PROJECT $GIT_PROJECT from $(pwd)"
echo "SCRIPT_DIR IS $SCRIPT_DIR"

git remote set-url origin https://${GIT_AUTHOR_NAME}:${GIT_PASSWORD}@github.com/Activiti/$GIT_PROJECT.git

if [ -e "pom.xml" ]; then
    mvn ${MAVEN_ARGS:-clean install -DskipTests}
else
    echo "No pom.xml for $GIT_PROJECT - build straight from Dockerfile"
fi

if [ -e "Dockerfile" ]; then
    if [ -z "${SKIP_DOCKER_BUILD}" ]
    then
      docker build -t activiti/${GIT_PROJECT}:${RELEASE_VERSION} .
    fi
    if [ -n "${DOCKER_PUSH}" ]
    then
      docker push docker.io/activiti/${GIT_PROJECT}:${RELEASE_VERSION}
    fi
else
    echo "No Dockerfile for $GIT_PROJECT - not building image"
fi
