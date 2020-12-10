#!/usr/bin/env bash
set -e

GIT_PROJECT=$(basename $(pwd))

echo "BUILDING IMAGE FOR PROJECT $GIT_PROJECT from $(pwd)"
echo "SCRIPT_DIR IS $SCRIPT_DIR"

if [ -e "pom.xml" ]; then
    mvn ${MAVEN_ARGS:-clean install -DskipTests}
else
    echo "No pom.xml for $GIT_PROJECT - build straight from Dockerfile"
fi

if [ -e "package.json" ]; then
    sed -i -e "s/\"commit\": \".*\"/\"commit\": \"$(git rev-parse HEAD)\"/g" package.json
    sed -i -e "s/\"version\": \".*\"/\"version\": \"$RELEASE_VERSION\"/g" package.json
    npm install
    npm run build -- --prod
else
    echo "No package.json for $GIT_PROJECT - build straight from Dockerfile"
fi

if [ -e "Dockerfile" ]; then
    DOCKER_USER=${DOCKER_USER:-activiti}
    if [ -z "${SKIP_DOCKER_BUILD}" ]
    then
      if [ -e "package.json" ]; then
        docker build --build-arg PROJECT_NAME=modeling-ce -t ${DOCKER_USER}/${GIT_PROJECT}:${RELEASE_VERSION} .
      else
        docker build -t ${DOCKER_USER}/${GIT_PROJECT}:${RELEASE_VERSION} .
      fi
    fi
    if [ -n "${DOCKER_PUSH}" ]
    then
      docker push docker.io/${DOCKER_USER}/${GIT_PROJECT}:${RELEASE_VERSION}
    fi
else
    echo "No Dockerfile for $GIT_PROJECT - not building image"
fi
