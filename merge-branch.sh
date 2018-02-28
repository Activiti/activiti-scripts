#!/usr/bin/env bash
set -e

[ -z "$BRANCH" ] && exit

SCRIPT_DIR=$(dirname $0)

for PROJECT in ${PROJECTS:-activiti}
do
  REPOS="$REPOS $(cat $SCRIPT_DIR/repos-${PROJECT}.txt)"
done

echo SCRIPT_DIR=$SCRIPT_DIR
echo working with REPOS $REPOS

cd ${SRC_DIR:-~/src}
for REPO in $REPOS
do
  pushd $PWD > /dev/null
  echo "*************** MERGE $BRANCH IN $REPO - START ***************"
  if [ -d "$REPO" ]
  then
    cd $REPO
    git checkout develop
    git pull --rebase
    git checkout ${BRANCH} || break
    git pull --rebase
    git rebase develop
    git checkout develop
    git merge --no-ff --no-edit ${BRANCH}
    if [ -n "$PUSH" ]
    then
      echo "* pushing to origin"
      git push --force-with-lease --atomic origin $BRANCH develop
      git push origin :$BRANCH
      git branch -d $BRANCH
    fi
  fi
  echo "*************** MERGE $BRANCH IN $REPO - END ***************"
  popd > /dev/null
done