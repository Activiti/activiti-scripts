#!/usr/bin/env bash
set -e

export DEPLOY_EXISTING=${DEPLOY_EXISTING:-true}

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

export SRC_DIR=${PWD}/..

if [ "${CHECK_VERSIONS}" == "false" ]
then
  unset CHECK_VERSIONS
else
  export CHECK_VERSIONS=true
fi

./fetch-versions.sh Activiti "${ACTIVITI_CORE_VERSION}"
./fetch-versions.sh activiti-cloud-dependencies "${ACTIVITI_CLOUD_VERSION}"

#git commit -am "Update internal versions"
#git push origin master

./clone-all.sh
STAGING_REPOSITORY=$(< "${SONATYPE_STAGING_FILE}")
export STAGING_REPOSITORY
MAVEN_ARGS="clean install -DskipTests" ./release-all.sh
