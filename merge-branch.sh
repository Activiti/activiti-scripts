#!/usr/bin/env bash
set -e

[ -z "${BRANCH}" ] && exit

BASEBRANCH=develop

DEVEXISTS=$(git show-ref refs/heads/develop) || true

if [ -n "$DEVEXISTS" ];
  then
    echo 'using develop as base branch'
  else
    BASEBRANCH=master
fi
git checkout ${BASEBRANCH}
git pull --rebase
git checkout ${BRANCH} || break
git pull --rebase
git rebase ${BASEBRANCH}
git checkout ${BASEBRANCH}
git merge --no-ff --no-edit ${BRANCH}

if [ -n "${GIT_PUSH}" ]
then
  echo "* pushing to origin"
  git push --force-with-lease --atomic origin ${BRANCH} ${BASEBRANCH}
  git push origin :${BRANCH}
  git branch -d ${BRANCH}
fi
