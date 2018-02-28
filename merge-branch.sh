#!/usr/bin/env bash
set -e

[ -z "${BRANCH}" ] && exit

git checkout develop
git pull --rebase
git checkout ${BRANCH} || break
git pull --rebase
git rebase develop
git checkout develop
git merge --no-ff --no-edit ${BRANCH}

if [ -n "${PUSH}" ]
then
  echo "* pushing to origin"
  git push --force-with-lease --atomic origin ${BRANCH} develop
  git push origin :${BRANCH}
  git branch -d ${BRANCH}
fi
