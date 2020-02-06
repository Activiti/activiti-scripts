#!/usr/bin/env bash
set -e

mvn -version

if [ -z "${RELEASE_VERSION}" ]
then
  echo 'no override version set'
else
  echo 'override version' $RELEASE_VERSION
fi

if [ -z "${BASE_BRANCH}" ]
then
  echo 'no override set for base branch - will use script default'
else
  echo 'base branch' $BASE_BRANCH
fi

if [ "${DEPLOY_EXISTING}" == "true" ]
then
  echo 'will deploy existing repos'
else
  echo 'will not deploy existing repos'
fi

exit

export SRC_DIR=$(pwd)
export GIT_PUSH=true
export MAVEN_PUSH=
export DOCKER_PUSH=true

if [[ ${bamboo.check.versions} == "false" ]]
then
 export CHECK_VERSIONS=
else
 export CHECK_VERSIONS=true
fi

./clone-all.sh
export MAVEN_ARGS="--settings ../conf/settings.xml clean install -DskipTests"
export MAVEN_PUSH=

export PROJECTS=activiti-examples,activiti-cloud-examples,activiti-cloud-modeling-examples
./release-all.sh

export PROJECTS=activiti-cloud-examples,activiti-cloud-modeling-images
./dockerpush-all.sh

