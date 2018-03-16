#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

eval $(${SCRIPT_DIR}/new-release-env.sh)

echo SNAPSHOT_VERSION=${SNAPSHOT_VERSION}
echo RELEASE_VERSION=${RELEASE_VERSION}
echo NEXT_SNAPSHOT_VERSION=${NEXT_SNAPSHOT_VERSION}

#git config user.name "$GIT_AUTHOR_NAME"
#git config user.email "$GIT_AUTHOR_EMAIL"

git checkout -b release/${RELEASE_VERSION} develop

VERSION=${SNAPSHOT_VERSION} NEXT_VERSION=${RELEASE_VERSION} ${SCRIPT_DIR}/update-pom-version.sh

git commit -am "updating to release version ${RELEASE_VERSION}"
git checkout master
git merge --no-ff --no-edit release/${RELEASE_VERSION}

git tag -a ${RELEASE_VERSION} -m "tagging release ${RELEASE_VERSION}"
git checkout develop
git merge --no-ff --no-edit ${RELEASE_VERSION}
git branch -d release/${RELEASE_VERSION}

VERSION=${RELEASE_VERSION} NEXT_VERSION=${NEXT_SNAPSHOT_VERSION} ${SCRIPT_DIR}/update-pom-version.sh
git commit -am "updating to snapshot version ${NEXT_SNAPSHOT_VERSION}"

if [ -n "${PUSH}" ]
then
  echo "* pushing to origin"
  git push --atomic origin master develop ${RELEASE_VERSION}
fi
