#!/usr/bin/env bash
set -e

if [ -z "${bamboo.override.version}" ]
then
echo 'no override version set'
else
export RELEASE_VERSION=${bamboo.override.version}
echo 'override version' $RELEASE_VERSION
fi

if [ -z "${bamboo.base.branch}" ]
then
echo 'no override set for base branch - will use script default'
else
export BASEBRANCH=${bamboo.base.branch}
echo 'base branch' $BASEBRANCH
fi

if [[ ${bamboo.deploy.existing} == "true" ]]
then
export DEPLOY_EXISTING=${bamboo.deploy.existing}
echo 'will deploy existing repos'
else
echo 'will not deploy existing repos'
fi

export PROJECTS=activiti,activiti-cloud,activiti-cloud-modeling
export SRC_DIR=$(pwd)
export GIT_PUSH=true
export MAVEN_PUSH=true
export IGNORE_TAG_CHECKOUT_FAILURE=false

export BAMBOO_OPTS="-Dgpg.passphrase=${bamboo.gpg.passphrase} -Dgpg.homedir=${HOME}/.gnupg -Dusername=alfresco-build -Dpassword=${bamboo.github.password}"
echo $BAMBOO_OPTS
if [[ ${bamboo.check.versions} == "false" ]]
then
export CHECK_VERSIONS=
else
export CHECK_VERSIONS=true
fi

export DOCKER_USER=activiti

export MAVEN_ARGS="clean install -DskipTests --batch-mode -U"

git stash
git checkout ${TRAVIS_PULL_REQUEST_BRANCH:-${TRAVIS_BRANCH}}
./fetch-versions.sh activiti-dependencies 7.1.78
./fetch-versions.sh activiti-cloud-dependencies 7.1.159
./fetch-versions.sh activiti-cloud-modeling-dependencies 7.1.191
git config --global push.default current
git commit -am "[skip ci] Update internal versions"
git stash pop
git push https://${GITHUB_TOKEN}@github.com/Activiti/activiti-scripts.git

cd ..

./clone-all.sh
./build-all.sh
MAVEN_ARGS="clean install -DskipTests" ./release-all.sh

