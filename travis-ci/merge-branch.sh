#!/usr/bin/env bash
set -e

[ -z "${BRANCH}" ] && exit

BASEBRANCH=${BASEBRANCH:-develop}

BASEBRANCHEXISTS=$(git ls-remote origin ${BASEBRANCH}) || true

if [ -n "$BASEBRANCHEXISTS" ];
  then
    echo 'using' $BASEBRANCH 'as base branch'
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
